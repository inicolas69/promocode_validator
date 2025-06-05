require "rails_helper"

RSpec.describe Restriction::Age, type: :model do
  describe "validations" do
    subject { build(:restriction_age) }

    context "when eq, lt, and gt are all nil" do
      before {
        subject.conditions = {lt: nil, gt: nil, eq: nil}
      }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("At least one age condition must be specified (lt, gt, eq)")
      end
    end

    context "when lt and gt are present" do
      before {
        subject.conditions = {lt: 10, gt: 15}
      }

      it "is invalid if lt is not greater than gt" do
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("lt must be greater than gt")
      end

      it "is valid if lt is greater than gt" do
        subject.conditions = {lt: 20, gt: 15}
        expect(subject).to be_valid
      end

      it "is valid if lt is nil and gt is present" do
        subject.conditions = {lt: nil, gt: 15}
        expect(subject).to be_valid
      end

      it "is valid if gt is nil and lt is present" do
        subject.conditions = {lt: 20, gt: nil}
        expect(subject).to be_valid
      end
    end

    context "when eq is present with lt or gt" do
      before {
        subject.eq = 7
        subject.lt = 10
      }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("eq cannot be used with lt or gt")
      end
    end

    context "when eq is present without lt or gt" do
      before { subject.eq = 7 }

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end

  describe "database columns" do
    it { is_expected.to have_db_column(:type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:conditions).of_type(:jsonb).with_options(null: false, default: {"lt" => nil, "gt" => nil, "eq" => nil}) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:restriction_group) }
  end
end
