FactoryBot.define do
  factory :restriction do
    association :restriction_group
    conditions { {} }
    type { "DefaultRestrictionType" }
  end
end
