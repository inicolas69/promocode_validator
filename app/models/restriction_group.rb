class RestrictionGroup < ApplicationRecord
  belongs_to :restrictable, polymorphic: true
  has_many :restrictions, dependent: :destroy
  has_many :subgroups,
    class_name: "RestrictionGroup",
    as: :restrictable,
    dependent: :destroy

  def parent_group
    restrictable if restrictable.is_a?(RestrictionGroup)
  end
end
