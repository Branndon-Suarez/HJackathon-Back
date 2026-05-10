module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :validation_failed
    rescue_from ActiveRecord::RecordNotUnique, with: :conflict
    rescue_from ActiveRecord::DeleteRestrictionError, with: :delete_conflict
    rescue_from ActiveRecord::InvalidForeignKey, with: :delete_conflict
    rescue_from ActiveRecord::StaleObjectError, with: :conflict
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from JsonWebToken::AuthError, with: :unauthorized
    rescue_from ActionController::RoutingError, with: :not_found
    rescue_from StandardError, with: :internal_error
  end

  private

  def not_found(exception)
    render_error(
      code: ErrorCodes::RECORD_NOT_FOUND,
      message: exception.message,
      status: :not_found
    )
  end

  def validation_failed(exception)
    details = exception.record.errors.map do |error|
      { field: error.attribute, message: error.message }
    end

    render_error(
      code: ErrorCodes::VALIDATION_FAILED,
      message: "Validation failed",
      status: :unprocessable_entity,
      details: details
    )
  end

  def parameter_missing(exception)
    render_error(
      code: ErrorCodes::PARAMETER_MISSING,
      message: exception.message,
      status: :bad_request
    )
  end

  def conflict(exception)
    render_error(
      code: ErrorCodes::CONFLICT,
      message: exception.message,
      status: :conflict
    )
  end

  def delete_conflict(exception)
    render_error(
      code: ErrorCodes::CONFLICT,
      message: "Cannot delete: #{exception.message}",
      status: :conflict
    )
  end

  def unauthorized(exception)
    render_error(
      code: ErrorCodes::UNAUTHORIZED,
      message: exception.message,
      status: :unauthorized
    )
  end

  def internal_error(exception)
    Rails.logger.error("[#{self.class.name}] #{exception.class}: #{exception.message}")
    Rails.logger.error(exception.backtrace&.first(10)&.join("\n"))

    render_error(
      code: ErrorCodes::INTERNAL_ERROR,
      message: "Internal server error",
      status: :internal_server_error
    )
  end

  def render_error(code:, message:, status:, details: nil)
    render json: {
      error: {
        code: code,
        message: message,
        status: Rack::Utils.status_code(status),
        details: details
      }
    }, status: status
  end
end
