class Api::V1::PromoCodesController < ApplicationController
  # POST /promo_codes
  def create
    promo_code = ::PromoCodeBuilder.call(
      name: params[:name],
      advantage: params[:advantage],
      restrictions: params[:restrictions]
    )

    render json: {
      name: promo_code.name,
      advantage: promo_code.advantage,
      restrictions: promo_code.restriction_groups.map { |group| serialize_group(group) }
    }, status: :created
  rescue => e
    render json: {error: e.message}, status: :unprocessable_entity
  end

  private

  def promo_code_params
    params.require(:promo_code).permit(:name, :advantage, restrictions: [])
  end

  # Recursively serialize restriction groups with their operator and children
  def serialize_group(group)
    children = group.subgroups.map { |g| serialize_group(g) }
    restrictions = group.restrictions.map do |r|
      {r.class.name.demodulize.underscore => r.conditions}
    end

    {group.operator => restrictions + children}
  end
end
