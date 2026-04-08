class Dashboard::RestaurantsController < Dashboard::BaseController
  skip_before_action :set_restaurant, only: [:new, :create]

  def new
    @new_restaurant = Restaurant.new
  end

  def create
    @new_restaurant = Restaurant.new(new_restaurant_params)
    @new_restaurant.owner_id = current_user.uid.presence || current_user.id

    if @new_restaurant.save
      session[:current_restaurant_id] = @new_restaurant.id
      redirect_to dashboard_path, notice: "Restaurant \"#{@new_restaurant.name}\" created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def switch
    restaurant = current_user_restaurants.find { |r| r.id == params[:restaurant_id] }
    if restaurant
      session[:current_restaurant_id] = restaurant.id
    end
    redirect_to dashboard_path
  end

  private

  def new_restaurant_params
    params.require(:restaurant).permit(:name, :slug, :description)
  end
end
