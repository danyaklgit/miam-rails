class Admin::OverviewController < Admin::BaseController
  def show
    @total_restaurants = Restaurant.count
    @active_restaurants = Restaurant.where(status: "active").count
    @total_orders = Order.count
    @total_revenue = Order.where(status: "completed").sum(:total_amount)
    @total_users = User.count
    @orders_today = Order.where("created_at >= ?", Date.current.beginning_of_day).count
    @recent_restaurants = Restaurant.order(created_at: :desc).limit(5)
  end
end
