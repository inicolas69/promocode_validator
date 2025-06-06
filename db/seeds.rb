PromoCode.destroy_all
RestrictionGroup.destroy_all
Restriction.destroy_all

PromoCodeBuilder.call(
  name: "SUMMER50",
  advantage: {percent: 50},
  restrictions: [
    {"weather" => {"is" => "clear", "temp" => {"gt" => 20}}},
    {"age" => {"gt" => 18, "lt" => 30}}
  ]
)

PromoCodeBuilder.call(
  name: "ELDERLY_RAIN",
  advantage: {percent: 30},
  restrictions: [
    {"date" => {"after" => "2024-01-01", "before" => "2026-01-01"}},
    {"and" => [
      {"age" => {"gt" => 65}},
      {"weather" => {"is" => "rainy"}}
    ]}
  ]
)

PromoCodeBuilder.call(
  name: "WINTER_EXACT",
  advantage: {fixed: 10},
  restrictions: [
    {"date" => {"after" => "2025-12-01", "before" => "2026-03-01"}},
    {"or" => [
      {"age" => {"eq" => 42}},
      {"weather" => {"is" => "snow", "temp" => {"lt" => 0}}}
    ]}
  ]
)

PromoCodeBuilder.call(
  name: "BIRTHDAY_CLOUD",
  advantage: {percent: 20},
  restrictions: [
    {"date" => {"after" => Date.yesterday.to_s, "before" => (Time.zone.today + 7).to_s}},
    {"age" => {"eq" => 25}},
    {"weather" => {"is" => "clouds"}}
  ]
)

PromoCodeBuilder.call(
  name: "JUST_AGE",
  advantage: {percent: 5},
  restrictions: [
    {"age" => {"gt" => 10}}
  ]
)

PromoCodeBuilder.call(
  name: "MIXED_COMPLEX",
  advantage: {percent: 40},
  restrictions: [
    {"and" => [
      {"date" => {"after" => "2022-01-01", "before" => "2027-12-31"}},
      {"weather" => {"is" => "wind", "temp" => {"gt" => 10, "lt" => 30}}},
      {"or" => [
        {"age" => {"lt" => 18}},
        {"age" => {"gt" => 65}}
      ]}
    ]}
  ]
)

Rails.logger.debug "Sample promo codes with diverse restrictions created!"
