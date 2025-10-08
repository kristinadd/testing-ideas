class Api::BaseController < ApplicationController
  # Disable CSRF protection for all API endpoints
  protect_from_forgery with: :null_session

  # You can also add other API-specific configurations here:
  # - Authentication logic
  # - Rate limiting
  # - API versioning
  # - Common error handling
end
