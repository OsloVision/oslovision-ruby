# OsloVision Ruby Client

![oslo.vision](https://oslo.vision/images/blog/headers/header1.png)

<p align="center">
  <a href="https://oslo.vision">oslo.vision</a> • 
  <a href="https://github.com/OsloVision/training-notebooks">training notebooks</a> • 
  <a href="https://github.com/OsloVision/oslovision-ruby">ruby sdk</a> • 
  <a href="https://oslo.vision/blog">blog</a>
</p>

This Ruby gem provides a client for interacting with the Oslo API, a platform for creating and managing datasets for machine learning projects. The client allows you to easily upload images, create annotations, and download dataset exports.

## Features

- Simple interface for interacting with the Oslo API
- Support for adding images to projects
- Creation of annotations for images
- Downloading of dataset exports
- Automatic handling of authentication
- Comprehensive error handling

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oslovision'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install oslovision

## Usage

Here's a quick example of how to use the Oslo API client:

```ruby
require 'oslovision'

# Initialize the client
api = Oslovision.new("your_api_token_here")

# Test the API connection
puts api.test_api

# Add an image to a project
File.open("image.jpg", "rb") do |img_file|
  image_data = api.add_image("your_project_identifier", img_file)
  puts "Added image: #{image_data['id']}"

  # Create an annotation
  annotation = api.create_annotation(
    "your_project_identifier",
    image_data['id'],
    "cat",
    x0: 10,
    y0: 20,
    width_px: 100,
    height_px: 150
  )
  puts "Created annotation: #{annotation['id']}"
end

# Download an export
download_path = api.download_export("your_project_identifier", 1)
puts "Export downloaded to: #{download_path}"
```

## API Reference

### Oslovision.new(token, base_url: "https://app.oslo.vision/api/v1")

Initialize the Oslo API client.

- `token`: Your Oslo API authentication token
- `base_url`: The base URL of the Oslo API (optional)

### Methods

#### #test_api

Test if the API is up and running and the token is valid.

Returns a hash with the API test response.

#### #add_image(project_identifier, image, split: "train", status: "pending")

Add an image to a project.

- `project_identifier`: The ID of the project to add the image to
- `image`: Either a file object, file path string, or URL string of the image
- `split`: The dataset split for the image (default: "train")
- `status`: The status of the image (default: "pending")

Returns a hash with the added image's data.

#### #create_annotation(project_identifier, image_identifier, label, x0:, y0:, width_px:, height_px:)

Create a new annotation for an image.

- `project_identifier`: The ID of the project
- `image_identifier`: The ID of the image to annotate
- `label`: The label for the annotation
- `x0`, `y0`: The top-left coordinates of the bounding box
- `width_px`, `height_px`: The width and height of the bounding box in pixels

Returns a hash with the created annotation's data.

#### #download_export(project_identifier, version, output_dir: ".")

Download a dataset export and extract from the zip file.

- `project_identifier`: The ID of the project
- `version`: The version number of the export
- `output_dir`: The directory to save the downloaded files (default: current directory)

Returns the path to the downloaded export directory.

## Error Handling

The gem provides specific error classes for different types of failures:

- `Oslovision::AuthenticationError` - Invalid API token
- `Oslovision::NotFoundError` - Resource not found
- `Oslovision::ClientError` - Client-side errors (4xx HTTP status codes)
- `Oslovision::ServerError` - Server-side errors (5xx HTTP status codes)
- `Oslovision::APIError` - General API errors

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/OsloVision/oslovision-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/OsloVision/oslovision-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Oslovision project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/OsloVision/oslovision-ruby/blob/main/CODE_OF_CONDUCT.md).
