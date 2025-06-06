class PromoCodeValidator
  def self.call(promo_code:, user_data:)
    new(promo_code, user_data).call
  end

  def initialize(promo_code, user_data)
    @promo_code = promo_code
    @user_data = user_data.with_indifferent_access
  end

  def call
    enrich_with_weather_data if @user_data[:town].present?

    group = @promo_code.restriction_groups.first
    result = evaluate_group_with_reasons(group)
    if result[:valid]
      {promocode_name: @promo_code.name, status: "accepted", advantage: @promo_code.advantage}
    else
      {promocode_name: @promo_code.name, status: "denied", reasons: result[:reasons]}
    end
  end

  private

  def enrich_with_weather_data
    weather = fetch_weather_data(@user_data[:town])
    @user_data[:weather] = weather if weather
  end

  def fetch_weather_data(city)
    uri = URI("https://api.openweathermap.org/data/2.5/weather?q=#{CGI.escape(city)}&units=metric&appid=#{ENV["OPENWEATHER_API_KEY"]}")
    response = HTTParty.get(uri)

    return nil unless response.success?

    {
      conditions: response.dig("weather", 0, "main").downcase,
      temp: response.dig("main", "temp").to_f
    }
  rescue => e
    Rails.logger.warn("Weather API failed: #{e.message}")
    nil
  end

  def evaluate_group_with_reasons(group)
    valid = (group.operator == "and")
    reasons = []

    group.restrictions.each do |restriction|
      result = restriction.satisfies_condition(@user_data)
      if group.operator == "and"
        valid &&= result[:valid]
      else
        valid ||= result[:valid]
      end
      reasons.concat(result[:reasons]) unless result[:valid]
    end

    group.subgroups.each do |subgroup|
      result = evaluate_group_with_reasons(subgroup)
      if group.operator == "and"
        valid &&= result[:valid]
      else
        valid ||= result[:valid]
      end
      reasons.concat(result[:reasons]) unless result[:valid]
    end

    {valid: valid, reasons: reasons}
  end
end
