# frozen_string_literal: true

require "httparty"
require "mime/types"
require "json"
require "fileutils"
require "zip"

module Oslovision
  # Main client class for interacting with the Oslo API
  class Client
    include HTTParty

    # Initialize the Oslo API client
    #
    # @param token [String] Your Oslo API authentication token
    # @param base_url [String] The base URL of the Oslo API
    def initialize(token, base_url: "https://app.oslo.vision/api/v1")
      @token = token
      @base_url = base_url
      self.class.base_uri base_url
      self.class.headers "Authorization" => "Bearer #{token}"
      self.class.headers "User-Agent" => "oslovision-ruby/#{Oslovision::VERSION}"
    end

    # Test if the API is up and running and the token is valid
    #
    # @return [Hash] Response from the API test endpoint
    # @raise [Oslovision::APIError] If the API request fails
    def test_api
      response = self.class.get("/test")
      handle_response(response)
    end

    # Add an image to a project
    #
    # @param project_identifier [String] The ID of the project to add the image to
    # @param image [String, File, IO] Either a file path, file object, or URL string of the image
    # @param split [String] The dataset split for the image (default: "train")
    # @param status [String] The status of the image (default: "pending")
    # @return [Hash] Response containing the added image's data
    # @raise [Oslovision::APIError] If the API request fails
    def add_image(project_identifier, image, split: "train", status: "pending")
      if image.is_a?(String) && (image.start_with?("http://") || image.start_with?("https://"))
        # Handle URL
        body = {
          url: image,
          split: split,
          status: status,
          project_identifier: project_identifier
        }
        response = self.class.post("/images", body: body)
      else
        # Handle file upload
        file_data = prepare_file_data(image)
        body = {
          image: file_data,
          split: split,
          status: status,
          project_identifier: project_identifier
        }
        response = self.class.post("/images", body: body)
      end

      handle_response(response)
    end

    # Create a new annotation for an image
    #
    # @param project_identifier [String] The ID of the project
    # @param image_identifier [String] The ID of the image to annotate
    # @param label [String] The label for the annotation
    # @param x0 [Float] The x-coordinate of the top-left corner of the bounding box
    # @param y0 [Float] The y-coordinate of the top-left corner of the bounding box
    # @param width_px [Float] The width of the bounding box in pixels
    # @param height_px [Float] The height of the bounding box in pixels
    # @return [Hash] Response containing the created annotation's data
    # @raise [Oslovision::APIError] If the API request fails
    def create_annotation(project_identifier, image_identifier, label, x0:, y0:, width_px:, height_px:)
      body = {
        project_identifier: project_identifier,
        image_identifier: image_identifier,
        label: label,
        x0: x0,
        y0: y0,
        width_px: width_px,
        height_px: height_px
      }

      response = self.class.post("/annotations",
                                 body: body.to_json,
                                 headers: { "Content-Type" => "application/json" })
      handle_response(response)
    end

    # Download a dataset export and extract from the zip file
    #
    # @param project_identifier [String] The ID of the project
    # @param version [Integer] The version number of the export
    # @param output_dir [String] The directory to save the downloaded files (default: current directory)
    # @return [String] The path to the downloaded export directory
    # @raise [Oslovision::APIError] If the API request fails
    def download_export(project_identifier, version, output_dir: ".")
      response = self.class.get("/exports/#{version}?project_identifier=#{project_identifier}")
      
      if response.success?
        zip_path = File.join(output_dir, "#{project_identifier}_v#{version}.zip")
        extract_path = File.join(output_dir, "#{project_identifier}_v#{version}")

        # Write the zip file
        File.open(zip_path, "wb") do |file|
          file.write(response.body)
        end

        # Extract the zip file
        extract_zip(zip_path, extract_path)
        
        # Clean up the zip file
        File.delete(zip_path)
        
        extract_path
      else
        handle_response(response)
      end
    end

    private

    # Handle API response and raise appropriate errors
    #
    # @param response [HTTParty::Response] The HTTP response object
    # @return [Hash] The parsed response body
    # @raise [Oslovision::APIError] If the response indicates an error
    def handle_response(response)
      case response.code
      when 200..299
        if response.parsed_response.is_a?(String)
          JSON.parse(response.parsed_response)
        else
          response.parsed_response
        end
      when 401
        raise Oslovision::AuthenticationError, "Invalid API token"
      when 404
        raise Oslovision::NotFoundError, "Resource not found"
      when 400..499
        error_message = response.parsed_response&.dig("error") || "Client error"
        raise Oslovision::ClientError, error_message
      when 500..599
        raise Oslovision::ServerError, "Server error occurred"
      else
        raise Oslovision::APIError, "Unexpected response code: #{response.code}"
      end
    end

    # Prepare file data for upload
    #
    # @param image [String, File, IO] The image file or path
    # @return [File, IO] The file object ready for upload
    def prepare_file_data(image)
      case image
      when String
        # Assume it's a file path
        File.open(image, "rb")
      when File, IO, StringIO
        image
      else
        raise ArgumentError, "Invalid image type. Expected String (file path), File, or IO object"
      end
    end

    # Extract a zip file to a directory
    #
    # @param zip_path [String] Path to the zip file
    # @param extract_path [String] Directory to extract to
    def extract_zip(zip_path, extract_path)
      FileUtils.mkdir_p(extract_path)
      
      Zip::File.open(zip_path) do |zip_file|
        zip_file.each do |entry|
          entry_path = File.join(extract_path, entry.name)
          FileUtils.mkdir_p(File.dirname(entry_path))
          entry.extract(entry_path)
        end
      end
    end
  end
end
