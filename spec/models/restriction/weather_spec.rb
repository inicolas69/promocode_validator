require "rails_helper"

RSpec.describe Restriction::Weather, type: :model do
  describe "validations" do
    subject { build(:restriction_weather) }

    context "when conditions are empty" do
      before do
        subject.conditions = {}
      end

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("At least one weather condition must be specified (is, temp)")
      end
    end

    context "when 'is' is present" do
      before do
        subject.conditions = {is: "sunny"}
      end

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when 'temp' is present" do
      before do
        subject.conditions = {temp: {gt: 20, lt: 30}}
      end

      it "is valid with valid temp conditions" do
        expect(subject).to be_valid
      end

      it "is invalid if temp gt is not less than temp lt" do
        subject.conditions = {temp: {gt: 30, lt: 20}}
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("temp gt must be less than temp lt")
      end

      it "is invalid if temp eq is used with gt or lt" do
        subject.conditions = {temp: {eq: 25, gt: 20}}
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("temp eq cannot be used with gt or lt")
      end

      it "is invalid if temp conditions are not numeric" do
        subject.conditions = {temp: {gt: "hot", lt: 30}}
        expect(subject).not_to be_valid
        expect(subject.errors[:base]).to include("temp conditions must be numeric")
      end
    end

    context "when both 'is' and 'temp' are present" do
      before do
        subject.conditions = {is: "rainy", temp: {gt: 15, lt: 25}}
      end

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
