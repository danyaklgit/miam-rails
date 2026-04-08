class Admin::AnalyticsController < Admin::BaseController
  def index
    @period = params[:period] || "7d"
    days = { "24h" => 1, "7d" => 7, "30d" => 30, "90d" => 90 }[@period] || 7
    start_date = days.days.ago.beginning_of_day

    orders = Order.where("created_at >= ?", start_date)
    @total_orders = orders.count
    @total_revenue = orders.where(status: "completed").sum(:total_amount)
    @avg_order_value = @total_orders > 0 ? @total_revenue / [@total_orders, 1].max : 0
    @new_restaurants = Restaurant.where("created_at >= ?", start_date).count
    @orders_by_restaurant = orders.group(:restaurant_id).count
      .sort_by { |_, v| -v }.first(10)
      .map { |rid, count| [Restaurant.find(rid).name, count] }
    @revenue_by_restaurant = orders.where(status: "completed").group(:restaurant_id).sum(:total_amount)
      .sort_by { |_, v| -v }.first(10)
      .map { |rid, amount| [Restaurant.find(rid).name, amount] }
  end
end
