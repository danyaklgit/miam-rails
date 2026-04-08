class Customer::MenusController < Customer::BaseController
  def show
    @order_type = params[:type] || session[:order_type] || "takeaway"
    session[:order_type] = @order_type

    @menus = @restaurant.menus.active.sorted
    @active_menu = @menus.find { |m| m.id == params[:menu_id] } || @menus.first
    @categories = (@active_menu&.categories&.sorted || []).select { |c| c.menu_items.available.any? }
    @active_category = @categories.find { |c| c.id == params[:category_id] } || @categories.first
    @items = @active_category&.menu_items&.available&.sorted || []

    @cart = session[:cart] || { "items" => [], "restaurantId" => @restaurant.id }
    @cart_count = @cart["items"].sum { |i| i["quantity"] || 1 }
    @cart_subtotal = @cart["items"].sum { |i| ((i["price"].to_f + (i["variantPriceModifier"] || 0).to_f) * (i["quantity"] || 1)) }
  end
end
