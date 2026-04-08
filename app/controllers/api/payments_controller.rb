class Api::PaymentsController < Api::BaseController
  def create
    order = Order.find(params[:order_id])
    restaurant = order.restaurant
    stripe_config = restaurant.stripe || {}

    unless stripe_config["stripeAccountId"].present? && stripe_config["onboardingComplete"]
      return render json: { error: "Stripe not configured for this restaurant" }, status: :unprocessable_entity
    end

    amount_cents = (params[:amount].to_f * 100).round
    tip_cents = ((params[:tip_amount] || 0).to_f * 100).round
    total_cents = amount_cents + tip_cents
    platform_fee_cents = (total_cents * (stripe_config["platformFeePercent"] || 2) / 100.0).round

    payment_intent = Stripe::PaymentIntent.create(
      {
        amount: total_cents,
        currency: restaurant.currency.downcase,
        application_fee_amount: platform_fee_cents,
        metadata: {
          order_id: order.id,
          restaurant_id: restaurant.id
        }
      },
      { stripe_account: stripe_config["stripeAccountId"] }
    )

    payment = order.payments.create!(
      user_id: params[:user_id] || session[:device_id] || SecureRandom.uuid,
      amount: params[:amount],
      tip_amount: params[:tip_amount] || 0,
      stripe_payment_intent_id: payment_intent.id,
      status: "pending"
    )

    render json: {
      client_secret: payment_intent.client_secret,
      payment_id: payment.id,
      stripe_account_id: stripe_config["stripeAccountId"]
    }
  end
end
