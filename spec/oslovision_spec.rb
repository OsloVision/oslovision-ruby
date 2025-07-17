# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe Oslovision do
  it "has a version number" do
    expect(Oslovision::VERSION).not_to be nil
  end

  describe ".new" do
    it "creates a new client instance" do
      client = Oslovision.new("test_token")
      expect(client).to be_a(Oslovision::Client)
    end

    it "accepts custom base_url" do
      client = Oslovision.new("test_token", base_url: "https://custom.api.url")
      expect(client).to be_a(Oslovision::Client)
    end
  end
end

RSpec.describe Oslovision::Client do
  let(:token) { "test_token" }
  let(:base_url) { "https://app.oslo.vision/api/v1" }
  let(:client) { Oslovision::Client.new(token, base_url: base_url) }

  before do
    WebMock.disable_net_connect!
  end

  describe "#test_api" do
    context "when API responds successfully" do
      it "returns the response" do
        stub_request(:get, "#{base_url}/test")
          .with(headers: { "Authorization" => "Bearer #{token}" })
          .to_return(status: 200, body: '{"status": "ok"}', headers: { "Content-Type" => "application/json" })

        result = client.test_api
        expect(result).to eq({ "status" => "ok" })
      end
    end

    context "when API returns an error" do
      it "raises AuthenticationError for 401" do
        stub_request(:get, "#{base_url}/test")
          .to_return(status: 401, body: '{"error": "Unauthorized"}')

        expect { client.test_api }.to raise_error(Oslovision::AuthenticationError, "Invalid API token")
      end

      it "raises NotFoundError for 404" do
        stub_request(:get, "#{base_url}/test")
          .to_return(status: 404, body: '{"error": "Not Found"}')

        expect { client.test_api }.to raise_error(Oslovision::NotFoundError, "Resource not found")
      end
    end
  end

  describe "#add_image" do
    let(:project_id) { "test_project" }

    context "with URL" do
      it "sends POST request with URL" do
        image_url = "https://example.com/image.jpg"
        expected_response = { "id" => "image_123", "url" => image_url }

        stub_request(:post,"#{base_url}/images")
          .with(
            headers: { "Authorization" => "Bearer #{token}" },
            body: { url: image_url, split: "train", status: "pending", project_identifier: project_id }
          )
          .to_return(status: 200, body: expected_response.to_json)

        result = client.add_image(project_id, image_url)
        expect(result).to eq(expected_response)
      end
    end

    context "with file" do
      it "sends POST request with file" do
        file_content = "fake image data"
        file = StringIO.new(file_content)
        expected_response = { "id" => "image_123" }

        stub_request(:post, "#{base_url}/images")
          .with(headers: { "Authorization" => "Bearer #{token}" })
          .to_return(status: 200, body: expected_response.to_json)

        result = client.add_image(project_id, file)
        expect(result).to eq(expected_response)
      end
    end
  end

  describe "#create_annotation" do
    let(:project_id) { "test_project" }
    let(:image_id) { "test_image" }

    it "creates annotation with bounding box" do
      expected_response = { "id" => "annotation_123" }

      stub_request(:post, "#{base_url}/annotations")
        .with(
          headers: { 
            "Authorization" => "Bearer #{token}",
            "Content-Type" => "application/json"
          },
          body: {
            project_identifier: project_id,
            image_identifier: image_id,
            label: "cat",
            x0: 10,
            y0: 20,
            width_px: 100,
            height_px: 150
          }.to_json
        )
        .to_return(status: 200, body: expected_response.to_json)

      result = client.create_annotation(
        project_id,
        image_id,
        "cat",
        x0: 10,
        y0: 20,
        width_px: 100,
        height_px: 150
      )

      expect(result).to eq(expected_response)
    end
  end

  describe "#download_export" do
    let(:project_id) { "test_project" }
    let(:version) { 1 }

    it "downloads and extracts zip file" do
      # Mock zip file content
      zip_content = "fake zip content"

      stub_request(:get, "#{base_url}/exports/#{version}?project_identifier=#{project_id}")
        .with(headers: { "Authorization" => "Bearer #{token}" })
        .to_return(status: 200, body: zip_content)

      # Mock file operations
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:delete)
      allow(FileUtils).to receive(:mkdir_p)
      allow(client).to receive(:extract_zip)

      result = client.download_export(project_id, version, output_dir: "/tmp")

      expect(result).to eq("/tmp/#{project_id}_v#{version}")
    end
  end
end
