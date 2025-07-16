#!/usr/bin/env ruby
# frozen_string_literal: true

# Example usage of the OsloVision Ruby client
# Run this file with: ruby examples/basic_usage.rb

require_relative "../lib/oslovision"

# You would replace this with your actual API token
API_TOKEN = ENV["OSLO_API_TOKEN"] || "your_api_token_here"
PROJECT_ID = "your_project_identifier"

# Initialize the client
puts "Initializing OsloVision client..."
client = Oslovision.new(API_TOKEN)

begin
  # Test the API connection
  puts "Testing API connection..."
  result = client.test_api
  puts "API Test Result: #{result}"

  # Example: Add an image from URL
  puts "\nAdding image from URL..."
  image_url = "https://example.com/sample-image.jpg"
  # Uncomment the following lines to actually make API calls:
  # image_data = client.add_image(PROJECT_ID, image_url)
  # puts "Added image: #{image_data['id']}"

  # Example: Create an annotation
  # annotation = client.create_annotation(
  #   PROJECT_ID,
  #   image_data['id'],
  #   "cat",
  #   x0: 10,
  #   y0: 20,
  #   width_px: 100,
  #   height_px: 150
  # )
  # puts "Created annotation: #{annotation['id']}"

  # Example: Download an export
  # download_path = client.download_export(PROJECT_ID, 1)
  # puts "Export downloaded to: #{download_path}"

rescue Oslovision::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
  puts "Please check your API token."
rescue Oslovision::APIError => e
  puts "API error occurred: #{e.message}"
rescue => e
  puts "An error occurred: #{e.message}"
end

puts "\nExample completed!"
