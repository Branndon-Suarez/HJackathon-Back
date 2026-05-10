class HttpClient
  def self.post(url, body:, headers: {})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body.is_a?(String) ? body : body.to_json

    response = http.request(request)
    response
  rescue Net::TimeoutError => e
    Rails.logger.warn("[HttpClient] Timeout posting to #{url}: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.warn("[HttpClient] Error posting to #{url}: #{e.message}")
    nil
  end
end
