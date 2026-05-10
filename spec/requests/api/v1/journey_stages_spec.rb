require "rails_helper"

RSpec.describe "Api::V1::JourneyStages", type: :request do
  let(:headers) { auth_headers(create(:lead)) }

  describe "GET /api/v1/strategy_plans/:strategy_plan_id/journey_stages" do
    let(:strategy_plan) { create(:strategy_plan) }
    let!(:stages) { create_list(:journey_stage, 3, strategy_plan: strategy_plan) }

    it "returns stages ordered" do
      get "/api/v1/strategy_plans/#{strategy_plan.id}/journey_stages", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(3)
    end
  end

  describe "POST /api/v1/strategy_plans/:strategy_plan_id/journey_stages" do
    let(:strategy_plan) { create(:strategy_plan) }

    it "creates a stage" do
      post "/api/v1/strategy_plans/#{strategy_plan.id}/journey_stages",
           params: { journey_stage: { stage_name: "Test", order: 1 } },
           headers: headers

      expect(response).to have_http_status(:created)
      expect(json_body["data"]["stage_name"]).to eq("Test")
    end
  end

  describe "DELETE /api/v1/journey_stages/:id" do
    let!(:stage) { create(:journey_stage) }

    it "deletes the stage" do
      expect {
        delete "/api/v1/journey_stages/#{stage.id}", headers: headers
      }.to change(JourneyStage, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
