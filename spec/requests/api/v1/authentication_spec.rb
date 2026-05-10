require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "requests without token" do
    it "returns 401 for GET /api/v1/companies" do
      get "/api/v1/companies"

      expect(response).to have_http_status(:unauthorized)
      expect(json_body["error"]["code"]).to eq("UNAUTHORIZED")
    end

    it "returns 401 for POST /api/v1/companies" do
      post "/api/v1/companies", params: { company: { name: "Test" } }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for GET /api/v1/companies/:id" do
      get "/api/v1/companies/00000000-0000-0000-0000-000000000000"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for PATCH /api/v1/companies/:id" do
      patch "/api/v1/companies/00000000-0000-0000-0000-000000000000"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 for POST /api/v1/companies/:company_id/leads" do
      post "/api/v1/companies/00000000-0000-0000-0000-000000000000/leads"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "requests with invalid token" do
    let(:headers) { { "Authorization" => "Bearer invalid_token_123" } }

    it "returns 401" do
      get "/api/v1/companies", headers: headers

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "public endpoints" do
    it "POST /api/v1/auth/login is accessible" do
      post "/api/v1/auth/login", params: { email: "nonexistent@test.com" }

      expect(response).to have_http_status(:not_found)
    end

    it "GET /api/v1/health is accessible" do
      get "/api/v1/health"

      expect(response).to have_http_status(:ok)
    end

    it "GET /api/v1/ping is accessible" do
      get "/api/v1/ping"

      expect(response).to have_http_status(:ok)
    end
  end
end
