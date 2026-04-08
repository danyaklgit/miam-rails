class Customer::OrdersController < Customer::BaseController
  def show
    @order = Order.find(params[:order_id])
    @order_items = @order.order_items
    @is_delivery = @order.type == "delivery"

    @steps = if @is_delivery
      [
        { status: "confirmed", label: "Order confirmed" },
        { status: "preparing", label: "Preparing your order" },
        { status: "ready", label: "Ready" },
        { status: "outForDelivery", label: "Out for delivery" },
        { status: "completed", label: "Delivered" }
      ]
    else
      [
        { status: "confirmed", label: "Order confirmed" },
        { status: "preparing", label: "Preparing your order" },
        { status: "ready", label: "Ready for pickup" },
        { status: "completed", label: "Completed" }
      ]
    end

    status_order = @steps.map { |s| s[:status] }
    @current_step_index = status_order.index(@order.status) || 0
  end
end
