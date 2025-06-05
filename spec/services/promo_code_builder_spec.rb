require "rails_helper"

RSpec.describe PromoCodeBuilder do
  describe ".call" do
    it "creates a promo code with a simple restriction" do
      promo = PromoCodeBuilder.call(
        name: "SimpleCode",
        advantage: {percent: 10},
        restrictions: [
          {"date" => {"after" => "2022-01-01", "before" => "2023-01-01"}}
        ]
      )

      expect(promo).to be_persisted
      expect(promo.name).to eq("SimpleCode")
      expect(promo.advantage).to eq({"percent" => 10})
      expect(promo.restriction_groups.count).to eq(1)
      group = promo.restriction_groups.first
      expect(group.operator).to eq("and")
      expect(group.restrictions.first).to be_a(Restriction::Date)
      expect(group.restrictions.first.conditions).to eq({"after" => Date.parse("2022-01-01"), "before" => Date.parse("2023-01-01")})
    end

    it "creates nested groups with logical operators" do
      promo = PromoCodeBuilder.call(
        name: "NestedCode",
        advantage: {percent: 20},
        restrictions: [
          {
            "or" => [
              {"age" => {"eq" => 30}},
              {"and" => [
                {"weather" => {"is" => "sunny"}},
                {"date" => {"after" => "2021-01-01"}}
              ]}
            ]
          }
        ]
      )

      expect(promo).to be_persisted
      group = promo.restriction_groups.first
      expect(group.operator).to eq("and")
      expect(group.subgroups.first.operator).to eq("or")
      expect(group.subgroups.first.subgroups.last.operator).to eq("and")
      expect(group.subgroups.first.subgroups.last.restrictions.size).to eq(2)
    end

    it "creates a promo code with a weather restriction" do
      promo = PromoCodeBuilder.call(
        name: "WeatherCode",
        advantage: {percent: 15},
        restrictions: [
          {"weather" => {"is" => "rainy", "temp" => {"gt" => 10}}}
        ]
      )

      expect(promo).to be_persisted
      group = promo.restriction_groups.first
      restriction = group.restrictions.first
      expect(restriction).to be_a(Restriction::Weather)
      expect(restriction.conditions).to eq({"is" => "rainy", "temp" => {"gt" => 10}})
    end

    it "raises error on unknown restriction type" do
      expect {
        PromoCodeBuilder.call(
          name: "BadCode",
          advantage: {percent: 5},
          restrictions: [
            {"unknown" => {"foo" => "bar"}}
          ]
        )
      }.to raise_error(RuntimeError, /Unknown restriction type:.*unknown/)
    end
  end
end
