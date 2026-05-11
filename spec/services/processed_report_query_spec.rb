require "rails_helper"

RSpec.describe ProcessedReportQuery do
  let(:company) { create(:company) }
  let(:lead) { create(:lead, company: company) }
  let(:session_id) { "session-#{SecureRandom.hex(4)}" }
  let!(:diagnostic) { create(:diagnostic, lead: lead, session_id: session_id, status: :completed) }
  let!(:report) { create(:report, diagnostic: diagnostic, processed: true) }

  describe "#call" do
    subject { described_class.new(session_id).call }

    it "returns the report" do
      expect(subject).to eq(report)
    end

    context "session_id not found" do
      it "raises RecordNotFound" do
        expect { described_class.new("nonexistent").call }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end