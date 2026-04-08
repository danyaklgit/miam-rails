class Customer::BaseController < ApplicationController
  layout "customer"

  before_action :set_restaurant
  before_action :set_theme_variables

  private

  def set_restaurant
    @restaurant = Restaurant.find_by!(slug: params[:slug])
  end

  def set_theme_variables
    @theme = @restaurant.theme || {}
  end

  def device_id
    session[:device_id] ||= SecureRandom.uuid
  end
end
