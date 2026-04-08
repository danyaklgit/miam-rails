class Api::CartController < Api::BaseController
  def add
    cart = session[:cart] ||= { "items" => [], "restaurantId" => params[:restaurant_id] }
    cart["items"] << {
      "menuItemId" => params[:menu_item_id],
      "name" => params[:name],
      "price" => params[:price].to_f,
      "quantity" => (params[:quantity] || 1).to_i,
      "notes" => params[:notes] || "",
      "type" => params[:type] || "food",
      "variantId" => params[:variant_id],
      "variantName" => params[:variant_name],
      "variantPriceModifier" => (params[:variant_price_modifier] || 0).to_f
    }
    render json: { success: true, count: cart["items"].size }
  end

  def remove
    cart = session[:cart]
    return render(json: { success: false }) unless cart

    idx = params[:index].to_i
    cart["items"].delete_at(idx)
    render json: { success: true, count: cart["items"].size }
  end

  def update_quantity
    cart = session[:cart]
    return render(json: { success: false }) unless cart

    idx = params[:index].to_i
    qty = params[:quantity].to_i
    if qty <= 0
      cart["items"].delete_at(idx)
    else
      cart["items"][idx]["quantity"] = qty
    end
    render json: { success: true }
  end

  def clear
    session.delete(:cart)
    render json: { success: true }
  end
end
