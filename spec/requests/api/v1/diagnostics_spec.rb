require "rails_helper"

RSpec.describe "Api::V1::Diagnostics", type: :request do
  let(:headers) { auth_headers(create(:lead)) }

  describe "GET /api/v1/leads/:lead_id/diagnostics" do
    let(:lead) { create(:lead) }
    let!(:diagnostics) { create_list(:diagnostic, 2, lead: lead) }

    it "returns diagnostics" do
      get "/api/v1/leads/#{lead.id}/diagnostics", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(2)
    end
  end

  describe "POST /api/v1/leads/:lead_id/diagnostics" do
    let(:lead) { create(:lead) }

    it "creates a diagnostic" do
      post "/api/v1/leads/#{lead.id}/diagnostics",
           params: { diagnostic: { raw_responses: { q1: "Si" } } },
           headers: headers

      expect(response).to have_http_status(:created)
      expect(json_body["data"]["raw_responses"]["q1"]).to eq("Si")
    end
  end

  describe "PATCH /api/v1/diagnostics/:id" do
    let(:diagnostic) { create(:diagnostic) }

    it "returns 422 when reverting completed to pending" do
      diagnostic.update!(status: :completed)

      patch "/api/v1/diagnostics/#{diagnostic.id}",
            params: { diagnostic: { status: "pending" } },
            headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(json_body["error"]["code"]).to eq("CONFLICT")
    end
  end
end
