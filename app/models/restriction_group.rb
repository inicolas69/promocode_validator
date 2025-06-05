class RestrictionGroup < ApplicationRecord
  belongs_to :restrictable, polymorphic: true
  has_many :restrictions, dependent: :destroy
  has_many :restriction_groups, as: :restrictable, dependent: :destroy
end
