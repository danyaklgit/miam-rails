class Dashboard::MenuItemsController < Dashboard::BaseController
  def create
    category = @restaurant.categories.find(params[:category_id])
    category.menu_items.create!(menu_item_params.merge(menu: category.menu, restaurant: @restaurant))
    redirect_to dashboard_menu_path(menu_id: category.menu_id, category_id: category.id), notice: "Item created."
  end

  def update
    item = @restaurant.menu_items.find(params[:id])
    item.update!(menu_item_params)
    redirect_to dashboard_menu_path(menu_id: item.menu_id, category_id: item.category_id), notice: "Item updated."
  end

  def destroy
    item = @restaurant.menu_items.find(params[:id])
    menu_id = item.menu_id
    category_id = item.category_id
    item.destroy!
    redirect_to dashboard_menu_path(menu_id: menu_id, category_id: category_id), notice: "Item deleted."
  end

  private

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price, :type, :available, :sort_order, allergens: [], tags: [])
  end
end
