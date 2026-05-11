require "rails_helper"

RSpec.describe ProcessMessageJob do
  let(:conversation) { create(:chatbot_conversation) }

  context "with a user message" do
    let!(:user_message) do
      conversation.messages.create!(role: "user", content: "hola")
    end

    it "creates a bot response message" do
      expect {
        described_class.perform_now(user_message.id)
      }.to change { conversation.messages.reload.count }.by(1)

      bot_msg = conversation.messages.last
      expect(bot_msg.role).to eq("bot")
      expect(bot_msg.content).to be_present
    end
  end
end