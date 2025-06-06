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

  describe "#satisfies_condition" do
    subject { restriction.satisfies_condition(context) }

    let(:context) { {weather: {temp: current_temp, conditions: current_conditions}} }

    context "with only weather condition (is)" do
      let(:restriction) { build(:restriction_weather, is: "rainy", temp: {}) }

      context "when current condition matches" do
        let(:current_conditions) { "rainy" }
        let(:current_temp) { 20 }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when current condition does not match" do
        let(:current_conditions) { "sunny" }
        let(:current_temp) { 20 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The current weather condition does not match the required condition (rainy).")
        end
      end
    end

    context "with only temp gt condition" do
      let(:restriction) { build(:restriction_weather, is: "", temp: {"gt" => 18}) }
      let(:current_conditions) { "any" }

      context "when current temp is greater" do
        let(:current_temp) { 20 }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when current temp is equal" do
        let(:current_temp) { 18 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The current temperature (18) must be greater than 18.")
        end
      end

      context "when current temp is less" do
        let(:current_temp) { 10 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The current temperature (10) must be greater than 18.")
        end
      end
    end

    context "with only temp lt condition" do
      let(:restriction) { build(:restriction_weather, is: "", temp: {"lt" => 25}) }
      let(:current_conditions) { "any" }

      context "when current temp is less" do
        let(:current_temp) { 20 }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when current temp is equal" do
        let(:current_temp) { 25 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The current temperature (25) must be less than 25.")
        end
      end

      context "when current temp is greater" do
        let(:current_temp) { 30 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The current temperature (30) must be less than 25.")
        end
      end
    end

    context "with temp eq condition" do
      let(:restriction) { build(:restriction_weather, is: "", temp: {"eq" => 15}) }
      let(:current_conditions) { "any" }

      context "when current temp matches exactly" do
        let(:current_temp) { 15 }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
          expect(subject[:reasons]).to be_empty
        end
      end

      context "when current temp does not match" do
        let(:current_temp) { 10 }

        it "returns valid: false with reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The current temperature (10) must be exactly 15.")
        end
      end
    end

    context "with weather and temp conditions" do
      let(:restriction) { build(:restriction_weather, is: "clear", temp: {"gt" => 10, "lt" => 30}) }

      context "when both pass" do
        let(:current_conditions) { "clear" }
        let(:current_temp) { 20 }

        it "returns valid: true" do
          expect(subject[:valid]).to be true
        end
      end

      context "when only weather fails" do
        let(:current_conditions) { "cloudy" }
        let(:current_temp) { 20 }

        it "returns valid: false and returns weather reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The current weather condition does not match the required condition (clear).")
        end
      end

      context "when only temp fails" do
        let(:current_conditions) { "clear" }
        let(:current_temp) { 5 }

        it "returns valid: false and returns temp reason" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The current temperature (5) must be greater than 10.")
        end
      end

      context "when both fail" do
        let(:current_conditions) { "cloudy" }
        let(:current_temp) { 35 }

        it "returns valid: false and both reasons" do
          expect(subject[:valid]).to be false
          expect(subject[:reasons]).to include("The current weather condition does not match the required condition (clear).")
          expect(subject[:reasons]).to include("The current temperature (35) must be less than 30.")
        end
      end
    end
  end
end
