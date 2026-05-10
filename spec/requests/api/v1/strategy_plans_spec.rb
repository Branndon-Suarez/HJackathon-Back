require "rails_helper"

RSpec.describe "Api::V1::StrategyPlans", type: :request do
  let(:headers) { auth_headers(create(:lead)) }

  describe "GET /api/v1/diagnostics/:diagnostic_id/strategy_plan" do
    let(:strategy_plan) { create(:strategy_plan) }
    let(:diagnostic) { strategy_plan.diagnostic }

    it "returns the strategy plan" do
      get "/api/v1/diagnostics/#{diagnostic.id}/strategy_plan", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_body["data"]["id"]).to eq(strategy_plan.id)
    end

    it "returns 404 when no plan exists" do
      diagnostic = create(:diagnostic)

      get "/api/v1/diagnostics/#{diagnostic.id}/strategy_plan", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/diagnostics/:diagnostic_id/strategy_plan" do
    let(:diagnostic) { create(:diagnostic, status: :completed) }

    it "creates a strategy plan" do
      post "/api/v1/diagnostics/#{diagnostic.id}/strategy_plan",
           params: { strategy_plan: { executive_summary: "Plan summary" } },
           headers: headers

      expect(response).to have_http_status(:created)
      expect(json_body["data"]["executive_summary"]).to eq("Plan summary")
    end

    it "returns 409 when plan already exists" do
      create(:strategy_plan, diagnostic: diagnostic)

      post "/api/v1/diagnostics/#{diagnostic.id}/strategy_plan",
           params: { strategy_plan: { executive_summary: "Another" } },
           headers: headers

      expect(response).to have_http_status(:conflict)
      expect(json_body["error"]["code"]).to eq("CONFLICT")
    end
  end
end
