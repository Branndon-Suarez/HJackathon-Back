class Rack::Attack
  throttle("req/ip", limit: 100, period: 1.minute) do |req|
    req.ip
  end

  throttle("auth/ip", limit: 20, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/v1/") && req.post?
  end

  # Rate limit para webhooks de n8n
  throttle("webhooks/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/webhooks/")
  end

  self.throttled_responder = lambda do |_env|
    [
      429,
      { "Content-Type" => "application/json" },
      [ { error: "Rate limit exceeded. Try again later.", status: 429 }.to_json ]
    ]
  end
end

Rails.application.config.middleware.use Rack::Attack
