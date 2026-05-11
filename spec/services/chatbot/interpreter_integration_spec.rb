require "rails_helper"

RSpec.describe Chatbot::Interpreter do
  subject(:result) { described_class.new(text).call }

  describe "#integrations" do
    it "has a valid integration constant" do
      expect(Chatbot::Interpreter::INTENT_KEYWORDS).to be_a(Hash)
      expect(Chatbot::Interpreter::INTENT_KEYWORDS.keys).to include(:scoring, :help)
    end
  end
end