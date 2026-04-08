class Customer::LandingController < Customer::BaseController
  def show
    @menus = @restaurant.menus.active.sorted
    @active_menu = @menus.find { |m| m.id == params[:menu_id] } || @menus.first
    @categories = (@active_menu&.categories&.sorted || []).select { |c| c.menu_items.available.any? }
    @active_category = @categories.find { |c| c.id == params[:category_id] } || @categories.first
    @items = @active_category&.menu_items&.available&.sorted || []
  end
end
