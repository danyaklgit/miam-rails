class Display::BaseController < ApplicationController
  layout "display"

  before_action :set_restaurant

  private

  def set_restaurant
    id = params[:restaurant_id]
    @restaurant = id.match?(/\A[0-9a-f\-]{36}\z/) ? Restaurant.find(id) : Restaurant.find_by!(slug: id)
  end
end
