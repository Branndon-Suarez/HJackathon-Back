require "rails_helper"

RSpec.describe Chatbot::Orchestrator do
  let(:lead) { create(:lead) }
  let(:conversation) { create(:chatbot_conversation, lead: lead) }
  subject(:result) { described_class.new(conversation).call }

  describe "#call" do
    context "cold start (first user message)" do
      let(:conversation) do
        conv = create(:chatbot_conversation, lead: lead)
        conv.messages.create!(role: "user", content: "hola")
        conv
      end

      it "returns a welcome response" do
        expect(result[:type]).to eq("text")
        expect(result[:content]).to include("Hola")
        expect(result[:actions]).to be_a(Array)
      end
    end

    context "with scoring intent" do
      before do
        conversation.messages.create!(role: "user", content: "quiero hacer un diagnostico")
      end

      it "returns a scoring flow response" do
        expect(result[:type]).to eq("scoring_flow")
      end
    end

    context "with help intent" do
      before do
        conversation.messages.create!(role: "user", content: "que puedes hacer")
      end

      it "returns a help response with options" do
        expect(result[:type]).to eq("text")
        expect(result[:actions]).to be_a(Array)
      end
    end

    context "with cancel intent" do
      before do
        conversation.messages.create!(role: "user", content: "cancelar")
      end

      it "returns a farewell message" do
        expect(result[:type]).to eq("text")
        expect(result[:content]).to include("Hasta luego")
      end
    end

    context "with unknown intent" do
      before do
        conversation.messages.create!(role: "user", content: "xyzabcqwerty plmn")
      end

      it "returns a fallback response" do
        expect(result[:type]).to eq("text")
        expect(result[:actions]).to be_a(Array)
      end
    end
  end
end