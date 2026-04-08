class Dashboard::OrdersController < Dashboard::BaseController
  def index
    base = @restaurant.orders.includes(:order_items).order(created_at: :desc)

    @tab = params[:tab] || "current"
    @orders = case @tab
    when "current" then base.where(status: %w[pending confirmed preparing ready])
    when "upcoming" then base.where(type: %w[takeaway delivery], status: %w[pending confirmed])
    when "past" then base.where(status: %w[completed cancelled]).limit(50)
    else base.limit(50)
    end
  end

  def update
    order = @restaurant.orders.find(params[:id])
    order.update!(status: params[:status])
    redirect_to dashboard_orders_path(tab: params[:tab]), notice: "Order updated."
  end
end
