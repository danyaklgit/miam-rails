class Dashboard::BaseController < ApplicationController
  layout "dashboard"

  before_action :authenticate_user!
  before_action :set_restaurant

  private

  def set_restaurant
    @restaurant = current_user_restaurants.find { |r| r.id == session[:current_restaurant_id] }
    @restaurant ||= current_user_restaurants.first

    unless @restaurant
      redirect_to root_path, alert: "No restaurant found for your account."
    end
  end

  def current_user_restaurants
    @current_user_restaurants ||= Restaurant.where(owner_id: current_user.uid.presence || current_user.id)
  end
end
