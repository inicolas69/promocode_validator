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

  def satisfies_condition(context)
    current_weather = context[:weather] || {}

    temp_result = temp_check(current_weather[:temp])
    weather_result = weather_condition_check(current_weather[:conditions])

    all_reasons = temp_result[:reasons] + weather_result[:reasons]
    valid = temp_result[:valid] && weather_result[:valid]

    {valid: valid, reasons: all_reasons}
  end

  private

  def temp_check(current_temp)
    reasons = []
    return {valid: true, reasons: []} if temp.blank?
    if temp["gt"].present? && current_temp <= temp["gt"]
      reasons << "The current temperature (#{current_temp}) must be greater than #{temp["gt"]}."
    end
    if temp["lt"].present? && current_temp >= temp["lt"]
      reasons << "The current temperature (#{current_temp}) must be less than #{temp["lt"]}."
    end
    if temp["eq"].present? && current_temp != temp["eq"]
      reasons << "The current temperature (#{current_temp}) must be exactly #{temp["eq"]}."
    end

    {valid: reasons.empty?, reasons: reasons}
  end

  def weather_condition_check(current_weather)
    return {valid: true, reasons: []} if is.blank? || current_weather == is
    {valid: false, reasons: ["The current weather condition does not match the required condition (#{is})."]}
  end
end
