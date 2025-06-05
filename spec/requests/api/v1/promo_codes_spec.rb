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
end
