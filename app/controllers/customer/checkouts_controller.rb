class Customer::CheckoutsController < Customer::BaseController
  def show
    @order_type = session[:order_type] || "takeaway"
    @cart = session[:cart] || { "items" => [] }
    @cart_items = @cart["items"]
    @subtotal = @cart_items.sum { |i| ((i["price"].to_f + (i["variantPriceModifier"] || 0).to_f) * (i["quantity"] || 1)) }
    @discount = session[:discount] || 0
    @total = [@subtotal - @discount, 0].max
  end

  def create
    order_type = session[:order_type] || "takeaway"
    cart = session[:cart] || { "items" => [] }

    order = @restaurant.orders.create!(
      type: order_type,
      status: "pending",
      total_amount: params[:total],
      customer_info: {
        name: params[:customer_name],
        email: params[:customer_email],
        phone: params[:customer_phone]
      },
      delivery_address: order_type == "delivery" ? {
        street: params[:street],
        city: params[:city],
        postalCode: params[:postal_code],
        country: params[:country],
        instructions: params[:instructions]
      } : nil,
      pickup_time: params[:pickup_time],
      promo_code: params[:promo_code]
    )

    cart["items"].each do |item|
      order.order_items.create!(
        menu_item_id: item["menuItemId"],
        name: item["name"],
        price: item["price"],
        quantity: item["quantity"] || 1,
        notes: item["notes"] || "",
        type: item["type"] || "food",
        variant_id: item["variantId"],
        variant_name: item["variantName"],
        variant_price_modifier: item["variantPriceModifier"] || 0,
        ordered_by: device_id
      )
    end

    session.delete(:cart)
    session.delete(:discount)

    redirect_to "/#{@restaurant.slug}/order/#{order.id}"
  end
end
