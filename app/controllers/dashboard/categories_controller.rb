class Dashboard::CategoriesController < Dashboard::BaseController
  def create
    menu = @restaurant.menus.find(params[:menu_id])
    category = menu.categories.create!(category_params.merge(restaurant: @restaurant))
    redirect_to dashboard_menu_path(menu_id: menu.id, category_id: category.id), notice: "Category created."
  end

  def update
    category = @restaurant.categories.find(params[:id])
    category.update!(category_params)
    redirect_to dashboard_menu_path(menu_id: category.menu_id, category_id: category.id), notice: "Category updated."
  end

  def destroy
    category = @restaurant.categories.find(params[:id])
    menu_id = category.menu_id
    category.destroy!
    redirect_to dashboard_menu_path(menu_id: menu_id), notice: "Category deleted."
  end

  private

  def category_params
    params.require(:category).permit(:name, :description, :sort_order)
  end
end
