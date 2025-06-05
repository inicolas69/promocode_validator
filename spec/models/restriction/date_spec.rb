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
end
