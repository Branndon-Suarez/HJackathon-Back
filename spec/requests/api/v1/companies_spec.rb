require "rails_helper"

RSpec.describe "Api::V1::Companies", type: :request do
  let(:headers) { auth_headers(create(:lead)) }

  describe "GET /api/v1/companies" do
    let!(:companies) { create_list(:company, 3) }

    it "returns paginated companies" do
      get "/api/v1/companies", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(4)
      expect(json_body["meta"]).to include("current_page", "total_count")
    end
  end

  describe "GET /api/v1/companies/:id" do
    let(:company) { create(:company) }

    it "returns the company" do
      get "/api/v1/companies/#{company.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_body["data"]["id"]).to eq(company.id)
    end

    it "returns 404 for unknown id" do
      get "/api/v1/companies/00000000-0000-0000-0000-000000000000", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/companies" do
    let(:valid_params) do
      { company: { name: "New Corp", industry: "Tech", stage: "seed", team_size: 10 } }
    end

    it "creates a company" do
      post "/api/v1/companies", params: valid_params, headers: headers

      expect(response).to have_http_status(:created)
      expect(json_body["data"]["name"]).to eq("New Corp")
    end

    it "returns 422 with invalid params" do
      post "/api/v1/companies", params: { company: { name: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /api/v1/companies/:id" do
    let(:company) { create(:company) }

    it "updates the company" do
      patch "/api/v1/companies/#{company.id}",
            params: { company: { name: "Updated" } },
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_body["data"]["name"]).to eq("Updated")
    end
  end
end
