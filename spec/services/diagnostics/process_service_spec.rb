require "rails_helper"

RSpec.describe Diagnostics::ProcessService do
  subject(:service) { described_class.new(diagnostic) }

  let(:diagnostic) { create(:diagnostic, status: :pending) }

  describe "#call" do
    it "sets status to processing then completed" do
      service.call
      expect(diagnostic.reload.status).to eq("completed")
    end

    it "calculates the fit score" do
      service.call
      expect(diagnostic.reload.fit_score).to be_present
    end

    it "reports status as failed on error" do
      allow_any_instance_of(Diagnostics::CalculateFitScoreService).to receive(:call).and_raise(StandardError)

      expect { service.call }.to raise_error(StandardError)
      expect(diagnostic.reload.status).to eq("failed")
    end
  end
end
