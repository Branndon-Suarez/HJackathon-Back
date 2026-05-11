require "rails_helper"

RSpec.describe "Api::V1::Chatbot::Conversations", type: :request do
  let(:lead) { create(:lead) }
  let(:headers) { auth_headers(lead) }

  describe "GET /api/v1/chatbot/conversations" do
    let!(:c1) { create(:chatbot_conversation, lead: lead, created_at: 1.day.ago) }
    let!(:c2) { create(:chatbot_conversation, lead: create(:lead), created_at: Time.current) }

    it "returns conversations for current lead" do
      get "/api/v1/chatbot/conversations", headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(1)
    end
  end

  describe "GET /api/v1/chatbot/conversations/:id" do
    let!(:conversation) { create(:chatbot_conversation, lead: lead) }

    it "returns the conversation" do
      get "/api/v1/chatbot/conversations/#{conversation.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for unknown id" do
      get "/api/v1/chatbot/conversations/#{SecureRandom.uuid}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/chatbot/conversations" do
    it "creates a conversation" do
      expect {
        post "/api/v1/chatbot/conversations",
             params: { conversation: {} },
             headers: headers
      }.to change(Chatbot::Conversation, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "enforces one active conversation per lead" do
      create(:chatbot_conversation, lead: lead, status: "active")
      post "/api/v1/chatbot/conversations",
           params: { conversation: {} },
           headers: headers
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /api/v1/chatbot/conversations/:id" do
    let!(:conversation) { create(:chatbot_conversation, lead: lead, status: "active") }

    it "updates the conversation status" do
      patch "/api/v1/chatbot/conversations/#{conversation.id}",
            params: { conversation: { status: "paused" } }, headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/v1/chatbot/conversations/:id" do
    let!(:conversation) { create(:chatbot_conversation, lead: lead) }

    it "deletes the conversation" do
      expect {
        delete "/api/v1/chatbot/conversations/#{conversation.id}", headers: headers
      }.to change(Chatbot::Conversation, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "POST /api/v1/chatbot/conversations/:id/add_message" do
    let!(:conversation) { create(:chatbot_conversation, lead: lead) }

    it "adds a message and enqueues processing" do
      expect {
        post "/api/v1/chatbot/conversations/#{conversation.id}/add_message",
             params: { message: { content: "Hola" } },
             headers: headers
      }.to have_enqueued_job(ProcessMessageJob)
      expect(response).to have_http_status(:created)
    end
  end

  describe "GET /api/v1/chatbot/conversations/:id/get_messages" do
    let!(:conversation) { create(:chatbot_conversation, lead: lead) }

    before do
      create(:chatbot_message, conversation: conversation, role: "user")
      create(:chatbot_message, conversation: conversation, role: "bot")
    end

    it "returns messages" do
      get "/api/v1/chatbot/conversations/#{conversation.id}/get_messages",
          headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(2)
    end
  end
end