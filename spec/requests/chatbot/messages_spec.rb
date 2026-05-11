require "rails_helper"

RSpec.describe "Api::V1::Chatbot::Messages", type: :request do
  let(:lead) { create(:lead) }
  let(:conversation) { create(:chatbot_conversation, lead: lead) }
  let(:headers) { auth_headers(lead) }

  describe "GET /api/v1/chatbot/conversations/:conversation_id/messages" do
    before do
      create(:chatbot_message, conversation: conversation, role: "user")
      create(:chatbot_message, conversation: conversation, role: "bot")
    end

    it "returns messages" do
      get "/api/v1/chatbot/conversations/#{conversation.id}/messages",
          headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(2)
    end
  end

  describe "GET /api/v1/chatbot/messages/:id" do
    let!(:message) { create(:chatbot_message, conversation: conversation, role: "user") }

    it "returns a specific message" do
      get "/api/v1/chatbot/messages/#{message.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/chatbot/conversations/:conversation_id/messages" do
    it "creates a user message" do
      expect {
        post "/api/v1/chatbot/conversations/#{conversation.id}/messages",
             params: { message: { content: "Hola" } },
             headers: headers
      }.to have_enqueued_job(ProcessMessageJob)
      expect(response).to have_http_status(:created)
    end
  end

  describe "PATCH /api/v1/chatbot/messages/:id" do
    let!(:message) { create(:chatbot_message, conversation: conversation, role: "user") }

    it "updates the message" do
      patch "/api/v1/chatbot/messages/#{message.id}",
            params: { message: { content: "Nueva pregunta" } },
            headers: headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/v1/chatbot/messages/:id" do
    let!(:message) { create(:chatbot_message, conversation: conversation, role: "user") }

    it "deletes the message" do
      expect {
        delete "/api/v1/chatbot/messages/#{message.id}",
               params: {}, headers: headers
      }.to change(Chatbot::Message, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end