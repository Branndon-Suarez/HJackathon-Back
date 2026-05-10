class JsonWebToken
  SECRET_KEY = ENV.fetch("JWT_SECRET", "hackathon_secret_key_change_in_production")

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY).first
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    raise AuthError, e.message
  end

  class AuthError < StandardError; end
end
