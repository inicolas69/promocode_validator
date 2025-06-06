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

  describe "#satisfies_condition" do
    let(:context) { {age: user_age} }

    subject { restriction.satisfies_condition(context) }

    context "with only lt condition" do
      let(:restriction) { build(:restriction_age, lt: 30, gt: nil, eq: nil) }

      context "when age is less than lt" do
        let(:user_age) { 25 }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when age is equal to lt" do
        let(:user_age) { 30 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The age (30) must be less than 30.")
        end
      end

      context "when age is greater than lt" do
        let(:user_age) { 35 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The age (35) must be less than 30.")
        end
      end
    end

    context "with only gt condition" do
      let(:restriction) { build(:restriction_age, gt: 18, lt: nil, eq: nil) }

      context "when age is greater than gt" do
        let(:user_age) { 20 }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when age is equal to gt" do
        let(:user_age) { 18 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The age (18) must be greater than 18.")
        end
      end

      context "when age is less than gt" do
        let(:user_age) { 15 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The age (15) must be greater than 18.")
        end
      end
    end

    context "with only eq condition" do
      let(:restriction) { build(:restriction_age, eq: 42, lt: nil, gt: nil) }

      context "when age is exactly eq" do
        let(:user_age) { 42 }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when age is not eq" do
        let(:user_age) { 41 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The age (41) must be exactly 42.")
        end
      end
    end

    context "with gt and lt conditions" do
      let(:restriction) { build(:restriction_age, gt: 18, lt: 30, eq: nil) }

      context "when age is between gt and lt" do
        let(:user_age) { 25 }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when age fails both conditions" do
        let(:user_age) { 15 }

        it "returns valid: false with both reasons" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The age (15) must be greater than 18.")
        end
      end

      context "when age fails only one condition" do
        let(:user_age) { 35 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The age (35) must be less than 30.")
        end
      end
    end
  end
end
