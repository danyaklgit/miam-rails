class Customer::TablesController < Customer::BaseController
  def show
    load_table_data
    @menus = @restaurant.menus.active.sorted
    @active_menu = @menus.find { |m| m.id == params[:menu_id] } || @menus.first
    @categories = (@active_menu&.categories&.sorted || []).select { |c| c.menu_items.available.any? }
    @active_category = @categories.find { |c| c.id == params[:category_id] } || @categories.first
    @items = @active_category&.menu_items&.available&.sorted || []
  end

  def cart_drawer
    load_table_data
    render partial: "shared/dine_in_cart_drawer_content", locals: {
      order: @order,
      order_items: @order_items,
      restaurant: @restaurant,
      paid_amount: @order&.paid_amount.to_f
    }, layout: false
  end

  private

  def load_table_data
    @table = @restaurant.restaurant_tables.find_by!(number: params[:table_number])
    @session = @table.dining_sessions.active.last
    @members = @session&.session_members || []
    @order = @session&.order
    @order_items = @order&.order_items&.reload || []
    @theme = @restaurant.theme || {}
  end
end
