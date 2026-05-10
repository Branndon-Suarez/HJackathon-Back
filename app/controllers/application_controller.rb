class ApplicationController < ActionController::API
  include ErrorHandler

  around_action :log_request

  private

  def log_request
    start = Time.current
    yield
    duration = (Time.current - start).round(3)
    Rails.logger.info("[#{request.method}] #{request.path} -> #{response.status} (#{duration}s)")
  end

  def authenticate_request!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    @current_payload = JsonWebToken.decode(token) if token
  rescue JsonWebToken::AuthError => e
    raise e
  end
end
