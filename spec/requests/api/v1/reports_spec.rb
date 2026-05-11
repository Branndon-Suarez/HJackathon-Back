require "rails_helper"

RSpec.describe "Api::V1::Reports", type: :request do
  let(:company) { create(:company) }
  let(:lead) { create(:lead, company: company) }
  let(:diagnostic) { create(:diagnostic, lead: lead, status: :completed, session_id: "session-#{SecureRandom.hex(4)}") }

  let(:valid_headers) { { "Authorization" => "Bearer #{auth_token(lead)}" } }
  let(:invalid_headers) { { "Authorization" => "Bearer invalid_token" } }

  # ── GET /api/v1/reports ──────────────────────────────────
  describe "GET /index" do
    context "with valid auth" do
      before do
        create(:report, diagnostic: diagnostic, processed: true, overall_score: "good")
        get api_v1_reports_path, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the report in data" do
        json = json_body
        expect(json["data"]).to be_an(Array)
        expect(json["data"].first["overall_score"]).to eq("good")
      end

      it "includes pagination meta" do
        expect(json_body["meta"]).to include("current_page", "total_count")
      end
    end

    context "without auth" do
      it "returns 401" do
        get api_v1_reports_path
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # ── GET /api/v1/reports/:id ──────────────────────────────
  describe "GET /show" do
    let!(:report) { create(:report, diagnostic: diagnostic, processed: true) }

    context "owner lead" do
      it "returns the report" do
        get api_v1_report_path(report), headers: valid_headers
        expect(response).to have_http_status(:ok)
        expect(json_body["data"]["id"].to_i).to eq(report.id)
      end
    end

    context "different lead" do
      let(:other_lead) { create(:lead) }
      let(:other_headers) { { "Authorization" => "Bearer #{auth_token(other_lead)}" } }

      it "returns 401" do
        get api_v1_report_path(report), headers: other_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # ── GET /api/v1/reports/latest ───────────────────────────
  describe "GET /latest" do
    let!(:old_report) do
      d = create(:diagnostic, lead: lead, status: :completed)
      create(:report, diagnostic: d, processed: true, overall_score: "moderate", created_at: 1.day.ago)
    end
    let!(:new_report) do
      create(:report, diagnostic: diagnostic, processed: true, overall_score: "good")
    end

    it "returns the newest processed report" do
      get latest_api_v1_reports_path, headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json_body["data"]["overall_score"]).to eq("good")
    end
  end

  # ── GET /api/v1/reports?session_id= ─────────────────────
  describe "GET with session_id" do
    let!(:report) { create(:report, diagnostic: diagnostic, processed: true) }

    it "finds report by session_id" do
      get api_v1_reports_path(session_id: diagnostic.session_id), headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json_body["data"]["id"].to_i).to eq(report.id)
    end

    it "returns 404 for unknown session_id" do
      get api_v1_reports_path(session_id: "nonexistent"), headers: valid_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end