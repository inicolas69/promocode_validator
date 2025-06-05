class PromoCodeBuilder
  def self.call(name:, advantage:, restrictions:)
    new(name, advantage, restrictions).call
  end

  def initialize(name, advantage, restrictions)
    @name = name
    @advantage = advantage
    @restrictions_json = restrictions
  end

  def call
    ActiveRecord::Base.transaction do
      promo = PromoCode.create!(name: @name, advantage: @advantage)
      root_group = RestrictionGroup.create!(restrictable: promo, operator: "and")
      build_group(@restrictions_json, root_group)
      promo
    end
  end

  private

  def build_group(data_array, parent_group)
    data_array.each do |entry|
      entry = entry.to_unsafe_h if entry.is_a?(ActionController::Parameters)

      if logical_operator?(entry)
        operator, children = entry.first
        subgroup = RestrictionGroup.create!(restrictable: parent_group, operator: operator)
        build_group(children, subgroup)
      else
        type = determine_type(entry)
        key = entry.keys.first
        Restriction.create!(restriction_group: parent_group, type: type, conditions: entry[key])
      end
    end
  end

  def logical_operator?(entry)
    entry.is_a?(Hash) && ["and", "or"].include?(entry.keys.first)
  end

  def determine_type(entry)
    case entry.keys.first
    when "date" then "Restriction::Date"
    when "age" then "Restriction::Age"
    when "weather" then "Restriction::Weather"
    else
      raise "Unknown restriction type: #{entry}"
    end
  end
end
