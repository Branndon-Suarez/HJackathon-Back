require "rails_helper"

RSpec.describe Diagnostics::CalculateFitScoreService do
  subject(:service) { described_class.new(diagnostic) }

  describe "#call" do
    context "with all positive responses" do
      let(:diagnostic) { create(:diagnostic, raw_responses: { q1: "Si", q2: "yes", q3: "Si" }) }

      it "returns score 100" do
        result = service.call
        expect(result[:fit_score]).to eq(100)
      end
    end

    context "with all negative responses" do
      let(:diagnostic) { create(:diagnostic, raw_responses: { q1: "No", q2: "No" }) }

      it "returns score 0" do
        result = service.call
        expect(result[:fit_score]).to eq(0)
      end
    end

    context "with mixed responses" do
      let(:diagnostic) { create(:diagnostic, raw_responses: { q1: "Si", q2: "No" }) }

      it "returns correct percentage" do
        result = service.call
        expect(result[:fit_score]).to eq(50)
      end
    end

    context "with nil responses" do
      let(:diagnostic) { create(:diagnostic, raw_responses: nil) }

      it "returns score 0" do
        result = service.call
        expect(result[:fit_score]).to eq(0)
      end
    end
  end
end
