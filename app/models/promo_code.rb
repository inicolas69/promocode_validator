class PromoCode < ApplicationRecord
  has_many :restriction_groups, as: :restrictable, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :advantage, presence: true
end
