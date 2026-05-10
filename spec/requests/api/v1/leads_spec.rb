require "rails_helper"

RSpec.describe "Api::V1::Leads", type: :request do
  let(:headers) { auth_headers(create(:lead)) }

  describe "GET /api/v1/companies/:company_id/leads" do
    let(:company) { create(:company) }
    let!(:leads) { create_list(:lead, 3, company: company) }

    it "returns leads for the company" do
      get "/api/v1/companies/#{company.id}/leads", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(3)
    end
  end

  describe "POST /api/v1/companies/:company_id/leads" do
    let(:company) { create(:company) }

    it "creates a lead" do
      post "/api/v1/companies/#{company.id}/leads",
           params: { lead: { full_name: "Juan", email: "juan@test.com", role: "CEO" } },
           headers: headers

      expect(response).to have_http_status(:created)
      expect(json_body["data"]["email"]).to eq("juan@test.com")
    end

    it "returns 422 for duplicate email" do
      create(:lead, company: company, email: "dup@test.com")

      post "/api/v1/companies/#{company.id}/leads",
           params: { lead: { full_name: "Dup", email: "dup@test.com" } },
           headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /api/v1/leads/:id" do
    let(:lead) { create(:lead) }

    it "updates the lead" do
      patch "/api/v1/leads/#{lead.id}",
            params: { lead: { full_name: "Updated" } },
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_body["data"]["full_name"]).to eq("Updated")
    end
  end
end
