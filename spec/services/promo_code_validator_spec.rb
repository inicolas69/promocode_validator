require "rails_helper"

RSpec.describe PromoCodeValidator do
  let(:promo_code) { create(:promo_code) }
  let(:user_data) { {age: 25, date: Time.zone.today.to_s, city: "Paris"} }

  before do
    stub_request(:get, /api.openweathermap.org/).to_return(
      status: 200,
      body: {weather: [{main: "Clouds"}], main: {temp: 25}}.to_json,
      headers: {"Content-Type" => "application/json"}
    )
  end

  context "when all restrictions are satisfied" do
    before do
      restriction_group = create(:restriction_group, restrictable: promo_code, operator: "and")
      create(:restriction_age, restriction_group: restriction_group, gt: 18, lt: 30, eq: nil) # Pass
      create(:restriction_date, restriction_group: restriction_group, after: Date.yesterday, before: Date.tomorrow) # Pass
    end

    it "returns status accepted and the advantage" do
      result = described_class.new(promo_code, user_data).call
      expect(result[:status]).to eq("accepted")
      expect(result[:advantage]).to eq(promo_code.advantage)
      expect(result[:promocode_name]).to eq(promo_code.name)
    end
  end

  context "when at least one restriction fails" do
    before do
      restriction_group = create(:restriction_group, restrictable: promo_code, operator: "and")
      create(:restriction_age, restriction_group: restriction_group, gt: 30, lt: nil, eq: nil) # Fail
      create(:restriction_date, restriction_group: restriction_group, after: Date.yesterday, before: nil) # Pass
    end

    it "returns status denied with reasons" do
      result = described_class.new(promo_code, user_data).call
      expect(result[:status]).to eq("denied")
      expect(result[:reasons]).to include("The age (25) must be greater than 30.")
      expect(result[:reasons].size).to be >= 1
      expect(result[:promocode_name]).to eq(promo_code.name)
    end
  end

  context "when multiple restrictions fail" do
    before do
      restriction_group = create(:restriction_group, restrictable: promo_code, operator: "and")
      create(:restriction_age, restriction_group: restriction_group, gt: 30, lt: nil, eq: nil) # Fail
      create(:restriction_date, restriction_group: restriction_group, before: Date.yesterday, after: nil) # Fail
    end

    it "returns all failure reasons" do
      result = described_class.new(promo_code, user_data).call
      expect(result[:status]).to eq("denied")
      expect(result[:reasons]).to include("The age (25) must be greater than 30.")
      expect(result[:reasons].any? { |r| r =~ /must be before/ }).to be true
      expect(result[:reasons].size).to eq(2)
      expect(result[:promocode_name]).to eq(promo_code.name)
    end
  end

  context "with operator OR in restriction group" do
    before do
      restriction_group = create(:restriction_group, restrictable: promo_code, operator: "or")
      create(:restriction_age, restriction_group: restriction_group, gt: 18, lt: nil, eq: nil) # Pass
      create(:restriction_date, restriction_group: restriction_group, before: Date.yesterday, after: nil) # Fail
    end

    it "accepts if at least one restriction is satisfied" do
      result = described_class.new(promo_code, user_data).call
      expect(result[:status]).to eq("accepted")
      expect(result[:advantage]).to eq(promo_code.advantage)
      expect(result[:promocode_name]).to eq(promo_code.name)
    end
  end

  context "with nested subgroups" do
    before do
      subgroup = create(:restriction_group, operator: "and")
      create(:restriction_group, restrictable: promo_code, operator: "and", subgroups: [subgroup])
      create(:restriction_age, restriction_group: subgroup, gt: 18, lt: nil, eq: nil) # Pass
      create(:restriction_date, restriction_group: subgroup, before: Date.yesterday, after: nil) # Fail
    end

    it "returns reasons from subgroups" do
      result = described_class.new(promo_code, user_data).call
      expect(result[:status]).to eq("denied")
      expect(result[:reasons].any? { |r| r =~ /must be before/ }).to be true
      expect(result[:promocode_name]).to eq(promo_code.name)
    end
  end
end
