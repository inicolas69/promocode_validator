class RestrictionGroup < ApplicationRecord
  belongs_to :restrictable, polymorphic: true
end
