class Restriction < ApplicationRecord
  belongs_to :restriction_group

  validates :type, presence: true
  validates :conditions, presence: true
  validate :validate_conditions

  def validate_conditions
    raise NotImplementedError, "You must implement the validate_conditions method in the subclass"
  end

  def satisfies_condition(context)
    raise NotImplementedError, "You must implement the satisfies_condition method in the subclass"
  end
end
