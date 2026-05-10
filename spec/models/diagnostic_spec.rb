require "rails_helper"

RSpec.describe Diagnostic, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:lead) }
    it { is_expected.to have_one(:strategy_plan).dependent(:destroy) }
  end

  describe "enums" do
    it "defines statuses" do
      expect(Diagnostic.statuses).to eq(
        "pending" => 0,
        "processing" => 1,
        "completed" => 2,
        "failed" => 3
      )
    end
  end

  describe "factory" do
    it "is valid" do
      expect(build(:diagnostic)).to be_valid
    end
  end
end
