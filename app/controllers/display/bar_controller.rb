class Display::BarController < Display::BaseController
  def show
    @items = @restaurant.orders
      .joins(:order_items)
      .where(order_items: { type: "drink", status: %w[ordered preparing ready] })
      .select("order_items.*, orders.type as order_type, orders.table_id as order_table_id, orders.id as parent_order_id")
      .order("order_items.created_at ASC")

    @counts = {
      ordered: @items.count { |i| i.status == "ordered" },
      preparing: @items.count { |i| i.status == "preparing" },
      ready: @items.count { |i| i.status == "ready" }
    }

    @view_mode = params[:view] || "all"
  end
end
