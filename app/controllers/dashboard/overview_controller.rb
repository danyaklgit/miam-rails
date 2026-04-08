class Dashboard::OverviewController < Dashboard::BaseController
  def show
    @orders_today = @restaurant.orders.where("created_at >= ?", Date.current.beginning_of_day).count
    @revenue_today = @restaurant.orders.where("created_at >= ?", Date.current.beginning_of_day).where(status: "completed").sum(:total_amount)
    @active_sessions = @restaurant.dining_sessions.active.count
    @reservations_today = @restaurant.reservations.where(date: Date.current.to_s).count
    @pending_orders = @restaurant.orders.where(status: %w[pending confirmed]).count
    @recent_orders = @restaurant.orders.order(created_at: :desc).limit(5)
  end
end
