class Admin::RestaurantsController < Admin::BaseController
  def index
    @restaurants = Restaurant.order(created_at: :desc)
    @restaurants = @restaurants.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @restaurants = @restaurants.page(params[:page]) if @restaurants.respond_to?(:page)
  end

  def show
    @restaurant = Restaurant.find(params[:id])
    @orders_count = @restaurant.orders.count
    @revenue = @restaurant.orders.where(status: "completed").sum(:total_amount)
    @tables_count = @restaurant.restaurant_tables.count
    @menus_count = @restaurant.menus.count
  end

  def update
    restaurant = Restaurant.find(params[:id])
    restaurant.update!(restaurant_params)
    redirect_to admin_restaurant_path(restaurant), notice: "Restaurant updated."
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:status, :stripe)
  end
end
