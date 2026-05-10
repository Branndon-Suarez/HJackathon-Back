require "rails_helper"

RSpec.describe JourneyStage, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:strategy_plan) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:stage_name) }
    it { is_expected.to validate_presence_of(:order) }
    it { is_expected.to validate_numericality_of(:order).only_integer }
  end

  describe "factory" do
    it "is valid" do
      expect(build(:journey_stage)).to be_valid
    end
  end
end
