require "rails_helper"

RSpec.describe PromoCode, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:restriction_groups).dependent(:destroy) }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      promo_code = PromoCode.new(name: "SUMMER2023", advantage: {percent: 20})
      expect(promo_code).to be_valid
    end

    it "is not valid without a name" do
      promo_code = PromoCode.new(name: nil, advantage: {percent: 20})
      expect(promo_code).not_to be_valid
    end

    it "is not valid with a duplicate name" do
      PromoCode.create(name: "SUMMER2023", advantage: {percent: 20})
      promo_code = PromoCode.new(name: "SUMMER2023", advantage: {percent: 30})
      expect(promo_code).not_to be_valid
    end

    it "is not valid without an advantage" do
      promo_code = PromoCode.new(name: "WINTER2023", advantage: nil)
      expect(promo_code).not_to be_valid
    end
  end
end
