require "rails_helper"

RSpec.describe RestrictionGroup, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:restrictable) }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      restriction_group = RestrictionGroup.new(restrictable: create(:promo_code))
      expect(restriction_group).to be_valid
    end

    it "is not valid without a restrictable" do
      restriction_group = RestrictionGroup.new(restrictable: nil)
      expect(restriction_group).not_to be_valid
    end
  end
end
