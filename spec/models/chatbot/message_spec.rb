require "rails_helper"

RSpec.describe Chatbot::Message, type: :model do
  let(:conversation) { create(:chatbot_conversation) }

  describe "associations" do
    it { is_expected.to belong_to(:conversation) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:content) }

    it "only allows user or bot as role" do
      message = build(:chatbot_message, role: "invalid")
      expect(message).not_to be_valid
      expect(message.errors[:role]).to include("is not included in the list")
    end
  end

  describe "factory" do
    subject { build(:chatbot_message, conversation: conversation) }
    it { is_expected.to be_valid }
  end

  describe "factory traits" do
    it "as_bot has role bot" do
      msg = build(:chatbot_message, :as_bot, conversation: conversation)
      expect(msg.role).to eq("bot")
    end

    it "default has role user" do
      msg = build(:chatbot_message, conversation: conversation)
      expect(msg.role).to eq("user")
    end
  end

  describe "scopes" do
    let!(:older) { create(:chatbot_message, conversation: conversation, created_at: 1.hour.ago) }
    let!(:newer) { create(:chatbot_message, conversation: conversation) }

    it ".ordered returns messages sorted by created_at asc" do
      expect(conversation.messages.ordered.pluck(:id)).to eq([older.id, newer.id])
    end
  end
end