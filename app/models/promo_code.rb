class PromoCode < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :advantage, presence: true
end
