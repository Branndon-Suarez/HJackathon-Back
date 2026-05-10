module RequestSpecHelper
  def json_body
    JSON.parse(response.body)
  end

  def auth_token(lead)
    payload = { lead_id: lead.id, company_id: lead.company_id }
    JsonWebToken.encode(payload)
  end

  def auth_headers(lead)
    { "Authorization" => "Bearer #{auth_token(lead)}" }
  end
end
