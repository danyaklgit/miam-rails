class Dashboard::MenusController < Dashboard::BaseController
  def index
    @menus = @restaurant.menus.sorted.includes(categories: :menu_items)
    @active_menu = @menus.find { |m| m.id == params[:menu_id] } || @menus.first
    @active_category = @active_menu&.categories&.sorted&.find { |c| c.id == params[:category_id] }
    @active_category ||= @active_menu&.categories&.sorted&.first
  end

  def create
    menu = @restaurant.menus.create!(menu_params)
    redirect_to dashboard_menu_path(menu_id: menu.id), notice: "Menu created."
  end

  def update
    menu = @restaurant.menus.find(params[:id])
    menu.update!(menu_params)
    redirect_to dashboard_menu_path(menu_id: menu.id), notice: "Menu updated."
  end

  def destroy
    menu = @restaurant.menus.find(params[:id])
    menu.destroy!
    redirect_to dashboard_menu_path, notice: "Menu deleted."
  end

  private

  def menu_params
    params.require(:menu).permit(:name, :description, :is_active, :sort_order)
  end
end
