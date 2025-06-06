class Restriction::Age < Restriction
  store_attribute :conditions, :lt, :integer, default: nil
  store_attribute :conditions, :gt, :integer, default: nil
  store_attribute :conditions, :eq, :integer, default: nil

  def validate_conditions
    if [lt, gt, eq].all?(&:nil?) || [lt, gt, eq].compact.all?(&:zero?)
      errors.add(:base, "At least one age condition must be specified (lt, gt, eq)")
      return
    end

    if lt.present? && gt.present? && lt <= gt
      errors.add(:base, "lt must be greater than gt")
    end

    if eq.present? && (lt.present? || gt.present?)
      errors.add(:base, "eq cannot be used with lt or gt")
    end
  end

  def satisfies_condition(context)
    reasons = []
    age = context[:age].to_i

    if lt.present? && !(age < lt)
      reasons << "The age (#{age}) must be less than #{lt}."
    end
    if gt.present? && !(age > gt)
      reasons << "The age (#{age}) must be greater than #{gt}."
    end
    if eq.present? && age != eq
      reasons << "The age (#{age}) must be exactly #{eq}."
    end

    {valid: reasons.empty?, reasons: reasons}
  end
end
