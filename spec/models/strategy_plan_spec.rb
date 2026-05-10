require "rails_helper"

RSpec.describe StrategyPlan, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:diagnostic) }
    it { is_expected.to have_many(:journey_stages).dependent(:destroy) }
  end

  describe "factory" do
    it "is valid" do
      expect(build(:strategy_plan)).to be_valid
    end
  end
end
