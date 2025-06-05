require "rails_helper"

RSpec.describe RestrictionGroup, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:restrictable) }
    it { is_expected.to have_many(:restrictions).dependent(:destroy) }
    it { is_expected.to have_many(:subgroups).class_name("RestrictionGroup").dependent(:destroy) }
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

  describe "#parent_group" do
    it "returns the parent group if restrictable is a RestrictionGroup" do
      parent_group = create(:restriction_group)
      subgroup = create(:restriction_group, restrictable: parent_group)

      expect(subgroup.parent_group).to eq(parent_group)
    end

    it "returns nil if restrictable is not a RestrictionGroup" do
      promo_code = create(:promo_code)
      restriction_group = create(:restriction_group, restrictable: promo_code)

      expect(restriction_group.parent_group).to be_nil
    end
  end
end
