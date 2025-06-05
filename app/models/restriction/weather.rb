class Restriction::Weather < Restriction
  store_attribute :conditions, :is, :string, default: ""
  store_attribute :conditions, :temp, :jsonb, default: {}

  def validate_conditions
    if is.blank? && temp.blank?
      errors.add(:base, "At least one weather condition must be specified (is, temp)")
      return
    end

    if temp&.values&.compact&.any? { |v| !v.is_a?(Numeric) }
      errors.add(:base, "temp conditions must be numeric")
      return
    end

    if temp.present?
      if temp["gt"].present? && temp["lt"].present? && temp["gt"] >= temp["lt"]
        errors.add(:base, "temp gt must be less than temp lt")
      end

      if temp["eq"].present? && (temp["gt"].present? || temp["lt"].present?)
        errors.add(:base, "temp eq cannot be used with gt or lt")
      end
    end
  end
end
