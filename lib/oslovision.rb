# frozen_string_literal: true

require_relative "oslovision/version"
require_relative "oslovision/client"
require_relative "oslovision/errors"

# OsloVision Ruby Client
#
# This module provides a Ruby client for interacting with the Oslo API,
# a platform for creating and managing datasets for machine learning projects.
module Oslovision
  class Error < StandardError; end

  # Create a new OsloVision client instance
  #
  # @param token [String] Your Oslo API authentication token
  # @param base_url [String] The base URL of the Oslo API (default: "https://app.oslo.vision/api/v1")
  # @return [Oslovision::Client] A new client instance
  def self.new(token, base_url: "https://app.oslo.vision/api/v1")
    Client.new(token, base_url: base_url)
  end
end
