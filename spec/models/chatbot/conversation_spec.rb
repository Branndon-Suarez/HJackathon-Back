require "rails_helper"

RSpec.describe Chatbot::Conversation, type: :model do
  let(:lead) { create(:lead) }

  describe "associations" do
    it { is_expected.to belong_to(:lead) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(%i[active paused completed archived]) }
  end

  describe "factory" do
    subject { build(:chatbot_conversation, lead: lead) }
    it { is_expected.to be_valid }
  end

  describe "uniqueness scope" do
    let!(:existing) { create(:chatbot_conversation, lead: lead, status: :active) }

    it "prevents duplicate active conversations for the same lead" do
      new_conv = build(:chatbot_conversation, lead: lead, status: :active)
      expect(new_conv).not_to be_valid
    end

    it "allows a new conversation if existing is paused" do
      existing.update!(status: :paused)
      new_conv = build(:chatbot_conversation, lead: lead, status: :active)
      expect(new_conv).to be_valid
    end
  end

  describe ".ordered" do
    let!(:old) { create(:chatbot_conversation, lead: lead, created_at: 1.day.ago) }
    let!(:recent) { create(:chatbot_conversation, lead: create(:lead), created_at: Time.current) }

    it "returns conversations ordered by created_at asc" do
      expect(described_class.where(lead_id: lead.id).ordered.to_a).to eq([old])
    end
  end

  describe "status scopes" do
    let!(:active_conv) { create(:chatbot_conversation, status: :active) }
    let!(:paused_conv) { create(:chatbot_conversation, status: :paused) }

    it "filters by active" do
      expect(described_class.active).to contain_exactly(active_conv)
    end

    it "filters by paused" do
      expect(described_class.paused).to contain_exactly(paused_conv)
    end
  end
end