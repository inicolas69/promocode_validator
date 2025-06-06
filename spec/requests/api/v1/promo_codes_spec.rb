require "rails_helper"

RSpec.describe "Api::V1::PromoCodes", type: :request do
  describe "POST /api/v1/promo_codes" do
    it "creates a promo code with a simple date restriction" do
      post "/api/v1/promo_codes", params: {
        name: "TestCode",
        advantage: {percent: 20},
        restrictions: [
          {"date" => {"after" => "2023-01-01", "before" => "2023-12-31"}}
        ]
      }, as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("TestCode")
      expect(body["advantage"]).to eq({"percent" => 20})
      expect(body["restrictions"]).to eq([
        {
          "and" => [
            {"date" => {"after" => "2023-01-01", "before" => "2023-12-31"}}
          ]
        }
      ])
    end

    it "creates a promo code with nested logical restrictions" do
      post "/api/v1/promo_codes", params: {
        name: "LogicCode",
        advantage: {percent: 10},
        restrictions: [
          {
            "or" => [
              {"age" => {"eq" => 30}},
              {
                "and" => [
                  {"weather" => {"is" => "clear", "temp" => {"gt" => 15}}},
                  {"date" => {"after" => "2023-01-01"}}
                ]
              }
            ]
          }
        ]
      }, as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["name"]).to eq("LogicCode")
      expect(body["advantage"]).to eq({"percent" => 10})
      expect(body["restrictions"]).to eq([
        {
          "and" => [
            {
              "or" => [
                {"age" => {"eq" => 30}},
                {
                  "and" => [
                    {"weather" => {"is" => "clear", "temp" => {"gt" => 15}}},
                    {"date" => {"after" => "2023-01-01"}}
                  ]
                }
              ]
            }
          ]
        }
      ])
    end

    it "returns error when restriction type is unknown" do
      post "/api/v1/promo_codes", params: {
        name: "InvalidCode",
        advantage: {percent: 5},
        restrictions: [
          {"unknown_type" => {"some" => "value"}}
        ]
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to match(/Unknown restriction type/)
    end

    it "returns error when name is missing" do
      post "/api/v1/promo_codes", params: {
        advantage: {percent: 10},
        restrictions: []
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to be_present
    end
  end

  describe "POST /promo_codes/validate" do
    let(:promo_code) { create(:promo_code, name: "SUMMER50") }

    context "when promo code does not exist" do
      it "returns not found" do
        post "/api/v1/promo_codes/validate", params: {promocode_name: "UNKNOWN", arguments: {}}
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to include("status" => "denied", "reasons" => ["Promo code not found"], "promocode_name" => "UNKNOWN")
      end
    end

    context "when promo code exists and is accepted" do
      before do
        # Ajoute des restrictions qui passent
        group = create(:restriction_group, restrictable: promo_code, operator: "and")
        create(:restriction_age, restriction_group: group, gt: 18, lt: 30, eq: nil)
      end

      it "returns accepted and advantage" do
        post "/api/v1/promo_codes/validate", params: {
          promocode_name: promo_code.name,
          arguments: {age: 25}
        }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("accepted")
        expect(json["advantage"]).to eq(promo_code.advantage)
        expect(json["promocode_name"]).to eq(promo_code.name)
      end
    end

    context "when promo code exists and is denied" do
      before do
        # Ajoute une restriction qui ne passe pas
        group = create(:restriction_group, restrictable: promo_code, operator: "and")
        create(:restriction_age, restriction_group: group, gt: 30, lt: nil, eq: nil)
      end

      it "returns denied and reasons" do
        post "/api/v1/promo_codes/validate", params: {
          promocode_name: promo_code.name,
          arguments: {age: 18}
        }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("denied")
        expect(json["reasons"]).to include("The age (18) must be greater than 30.")
        expect(json["promocode_name"]).to eq(promo_code.name)
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(PromoCode).to receive(:find_by).and_raise(StandardError, "Random error")
      end

      it "returns unprocessable_entity with error message" do
        post "/api/v1/promo_codes/validate", params: {promocode_name: "ANY", arguments: {}}
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("denied")
        expect(json["reasons"]).to eq(["Random error"])
        expect(json["promocode_name"]).to eq("ANY")
      end
    end
  end
end
