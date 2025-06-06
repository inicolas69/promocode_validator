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

  def satisfies_condition(context)
    reasons = []
    date_to_compare = context[:date].present? ? ::Date.parse(context[:date]) : Time.zone.today

    if after.present? && !(date_to_compare > after)
      reasons << "The date (#{date_to_compare}) must be after #{after}."
    end

    if before.present? && !(date_to_compare < before)
      reasons << "The date (#{date_to_compare}) must be before #{before}."
    end

    {valid: reasons.empty?, reasons: reasons}
  end
end
