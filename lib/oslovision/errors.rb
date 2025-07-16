# frozen_string_literal: true

module Oslovision
  # Base error class for all OsloVision-related errors
  class Error < StandardError; end

  # Error raised when API requests fail
  class APIError < Error; end

  # Error raised when authentication fails
  class AuthenticationError < APIError; end

  # Error raised when a resource is not found
  class NotFoundError < APIError; end

  # Error raised for client-side errors (4xx HTTP status codes)
  class ClientError < APIError; end

  # Error raised for server-side errors (5xx HTTP status codes)
  class ServerError < APIError; end
end
