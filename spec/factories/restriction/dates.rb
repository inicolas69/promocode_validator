FactoryBot.define do
  factory :restriction_date, class: "Restriction::Date" do
    type { "Restriction::Date" }
    association :restriction_group
    conditions do
      {
        before: "2023-12-31",
        after: "2023-01-01"
      }
    end
  end
end
