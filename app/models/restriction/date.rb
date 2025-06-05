class Restriction::Date < Restriction
  store_attribute :conditions, :after, :date, default: nil
  store_attribute :conditions, :before, :date, default: nil

  def validate_conditions
    if after.nil? && before.nil?
      errors.add(:base, "At least one date condition must be specified (after, before)")
      return
    end

    if after.present? && before.present? && after >= before
      errors.add(:base, "after must be earlier than before")
    end
  end

  def satisfied_by?(context)
    today = Time.zone.today
    after_condition = after.nil? || today > after
    before_condition = before.nil? || today < before
    after_condition && before_condition
  end
end
