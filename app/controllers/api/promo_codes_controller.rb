class Api::PromoCodesController < Api::BaseController
  def validate
    restaurant = Restaurant.find(params[:restaurant_id])
    offer = restaurant.offers.active.find_by(promo_code: params[:promo_code])

    unless offer
      return render json: { valid: false, error: "Invalid promo code" }
    end

    unless Offer.offer_currently_active?(offer)
      return render json: { valid: false, error: "This offer has expired" }
    end

    render json: {
      valid: true,
      offer: {
        id: offer.id,
        name: offer.name,
        type: offer.type,
        value: offer.value
      }
    }
  end
end
