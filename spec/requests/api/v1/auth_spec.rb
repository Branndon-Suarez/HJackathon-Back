require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/login" do
    let!(:lead) { create(:lead) }

    it "returns a token for an existing lead" do
      post "/api/v1/auth/login", params: { email: lead.email }

      expect(response).to have_http_status(:ok)
      expect(json_body["token"]).to be_present
      expect(json_body["lead"]["id"]).to eq(lead.id)
    end

    it "returns 404 for unknown email" do
      post "/api/v1/auth/login", params: { email: "unknown@test.com" }

      expect(response).to have_http_status(:not_found)
    end
  end
end
