class Display::OrdersController < Display::BaseController
  def show
    base = @restaurant.orders.where(type: %w[takeaway delivery]).includes(:order_items)

    @filter = params[:filter] || "active"
    @orders = case @filter
    when "active" then base.where(status: %w[pending confirmed preparing ready])
    when "takeaway" then base.where(type: "takeaway").where(status: %w[pending confirmed preparing ready])
    when "delivery" then base.where(type: "delivery").where(status: %w[pending confirmed preparing ready])
    else base.order(created_at: :desc).limit(50)
    end

    @orders = @orders.order(created_at: :desc)
  end
end
