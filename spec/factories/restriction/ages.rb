FactoryBot.define do
  factory :restriction_age, class: "Restriction::Age" do
    type { "Restriction::Age" }
    association :restriction_group
    conditions do
      {
        lt: nil,
        gt: nil,
        eq: 18
      }
    end
  end
end
