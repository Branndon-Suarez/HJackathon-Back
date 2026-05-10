class ApplicationController < ActionController::API
  include ErrorHandler

  around_action :log_request
  before_action :authenticate_request!

  private

  def log_request
    start = Time.current
    yield
    duration = (Time.current - start).round(3)
    Rails.logger.info("[#{request.method}] #{request.path} -> #{response.status} (#{duration}s)")
  end

  def authenticate_request!
    header = request.headers["Authorization"]
    raise JsonWebToken::AuthError, "Token is required" unless header

    token = header.split(" ").last
    raise JsonWebToken::AuthError, "Invalid authorization header" unless token

    @current_payload = JsonWebToken.decode(token)
  end
end
