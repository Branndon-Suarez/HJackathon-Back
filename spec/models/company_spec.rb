require "rails_helper"

RSpec.describe Company, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:leads).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "enums" do
    it "defines stages" do
      expect(Company.stages).to eq(
        "seed" => 0,
        "early_growth" => 1,
        "scaling" => 2,
        "mature" => 3
      )
    end
  end

  describe "factory" do
    it "is valid" do
      expect(build(:company)).to be_valid
    end
  end
end
