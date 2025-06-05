FactoryBot.define do
  factory :promo_code do
    sequence(:name) { |n| "PROMO#{n}" }
    advantage { {percent: 10} }
  end
end
