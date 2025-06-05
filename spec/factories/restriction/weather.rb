FactoryBot.define do
  factory :restriction_weather, class: "Restriction::Weather" do
    type { "Restriction::Weather" }
    association :restriction_group
    conditions do
      {
        is: "clear",
        temp: {
          gt: 15
        }
      }
    end
  end
end
