FactoryBot.define do
  factory :restriction_group do
    operator { "AND" }  # Default operator, can be changed in tests
    restrictable { association(:promo_code) }  # Default association, can be overridden
  end
end
