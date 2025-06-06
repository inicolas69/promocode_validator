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

  # POST /promo_codes/validate
  def validate
    promo_code = PromoCode.find_by(name: params[:promocode_name])

    unless promo_code
      return render json: {promocode_name: params[:promocode_name], status: "denied", reasons: ["Promo code not found"]}, status: :not_found
    end

    user_data = user_data_params.to_h
    result = ::PromoCodeValidator.call(promo_code: promo_code, user_data: user_data)

    render json: result, status: :ok
  rescue => e
    render json: {promocode_name: params[:promocode_name], status: "denied", reasons: [e.message]}, status: :unprocessable_entity
  end

  private

  def promo_code_params
    params.require(:promo_code).permit(:name, :advantage, restrictions: [])
  end

  def user_data_params
    params.require(:arguments).permit(:age, :town)
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
