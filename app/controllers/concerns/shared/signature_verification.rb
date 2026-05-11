module Shared
  module SignatureVerification
    extend ActiveSupport::Concern

    included do
      before_action :verify_webhook_signature, only: %i[receive]
    end

    private

    def verify_webhook_signature
      secret = webhook_secret
      # If no secret is configured, skip verification (development mode)
      return if secret.blank?

      signature = request.headers["X-N8N-Signature"] || request.headers["X-Webhook-Signature"]
      return head :unauthorized unless signature

      expected = OpenSSL::HMAC.hexdigest(
        "SHA256",
        secret,
        request.raw_post
      )

      unless ActiveSupport::SecurityUtils.secure_compare(signature, expected)
        return head :unauthorized
      end
    end

    def webhook_secret
      ENV.fetch("WEBHOOK_SECRET", nil)
    end
  end
end