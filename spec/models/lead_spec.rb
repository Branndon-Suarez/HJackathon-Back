require "rails_helper"

RSpec.describe Lead, type: :model do
  subject { create(:lead) }

  describe "associations" do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:diagnostics).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
  end

  describe "factory" do
    it "is valid" do
      expect(build(:lead)).to be_valid
    end
  end
end
