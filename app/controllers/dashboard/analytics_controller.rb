class Dashboard::AnalyticsController < Dashboard::BaseController
  def index
    @period = params[:period] || "7d"
    days = case @period
    when "24h" then 1
    when "7d" then 7
    when "30d" then 30
    else 7
    end

    start_date = days.days.ago.beginning_of_day
    orders = @restaurant.orders.where("created_at >= ?", start_date)

    @total_orders = orders.count
    @total_revenue = orders.where(status: "completed").sum(:total_amount)
    @avg_order_value = @total_orders > 0 ? @total_revenue / [@total_orders, 1].max : 0
    @orders_by_type = orders.group(:type).count
    @orders_by_status = orders.group(:status).count
    @daily_revenue = orders.where(status: "completed")
      .group("DATE(created_at)")
      .sum(:total_amount)
      .transform_keys { |k| k.to_s }
  end
end
