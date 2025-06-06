require "rails_helper"

RSpec.describe Restriction::Date, type: :model do
  describe "validations" do
    subject { build(:restriction_date) }

    context "when before and after are both nil" do
      before do
        subject.conditions = {before: nil, after: nil}
      end

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("At least one date condition must be specified (after, before)")
      end
    end

    context "when both before and after are present" do
      it "is invalid if after is not earlier than before" do
        subject.conditions = {before: Time.zone.today + 10, after: Time.zone.today + 15}
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("after must be earlier than before")
      end

      it "is valid if after is earlier than before" do
        subject.conditions = {before: Time.zone.today + 10, after: Time.zone.today + 5}
        expect(subject).to be_valid
      end

      it "is valid if before is nil and after is present" do
        subject.conditions = {before: nil, after: Time.zone.today + 5}
        expect(subject).to be_valid
      end

      it "is valid if after is nil and before is present" do
        subject.conditions = {before: Time.zone.today + 10, after: nil}
        expect(subject).to be_valid
      end
    end
  end

  describe "#satisfies_condition" do
    subject { restriction.satisfies_condition(context) }

    let(:today) { Date.new(2025, 6, 6) }
    let(:context) { {date: test_date.to_s} }

    context "with only after condition" do
      let(:restriction) { build(:restriction_date, after: today - 2, before: nil) }

      context "when date is after 'after'" do
        let(:test_date) { today }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when date is exactly 'after'" do
        let(:test_date) { today - 2 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The date (#{test_date}) must be after #{today - 2}.")
        end
      end

      context "when date is before 'after'" do
        let(:test_date) { today - 5 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The date (#{test_date}) must be after #{today - 2}.")
        end
      end
    end

    context "with only before condition" do
      let(:restriction) { build(:restriction_date, after: nil, before: today + 2) }

      context "when date is before 'before'" do
        let(:test_date) { today }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when date is exactly 'before'" do
        let(:test_date) { today + 2 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The date (#{test_date}) must be before #{today + 2}.")
        end
      end

      context "when date is after 'before'" do
        let(:test_date) { today + 5 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The date (#{test_date}) must be before #{today + 2}.")
        end
      end
    end

    context "with both after and before conditions" do
      let(:restriction) { build(:restriction_date, after: today - 2, before: today + 2) }

      context "when date is between after and before" do
        let(:test_date) { today }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when date is equal to after" do
        let(:test_date) { today - 2 }

        it "returns valid: false with after reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The date (#{test_date}) must be after #{today - 2}.")
        end
      end

      context "when date is equal to before" do
        let(:test_date) { today + 2 }

        it "returns valid: false with before reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The date (#{test_date}) must be before #{today + 2}.")
        end
      end

      context "when date fails both" do
        let(:test_date) { today - 10 }

        it "returns valid: false with after reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The date (#{test_date}) must be after #{today - 2}.")
        end
      end
    end
  end
end
