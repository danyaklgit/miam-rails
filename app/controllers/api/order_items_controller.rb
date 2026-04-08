class Api::OrderItemsController < Api::BaseController
  def update_status
    item = OrderItem.find(params[:id])
    item.update!(status: params[:status])
    render json: { success: true, id: item.id, status: item.status }
  end

  def bulk_update_status
    ids = params[:ids] || []
    new_status = params[:status]
    items = OrderItem.where(id: ids)
    items.find_each { |item| item.update!(status: new_status) }
    render json: { success: true, count: items.size }
  end

  def update_quantity
    item = OrderItem.find(params[:id])
    unless item.status == "pending"
      return render json: { error: "Can only change quantity of pending items" }, status: :unprocessable_entity
    end
    new_qty = params[:quantity].to_i
    if new_qty <= 0
      order = item.order
      item.destroy!
      order.recalculate_total!
      return render json: { success: true, order: order.reload }
    end
    item.update!(quantity: new_qty)
    item.order.recalculate_total!
    render json: { success: true, item: item, order: item.order.reload }
  end

  def destroy
    item = OrderItem.find(params[:id])
    unless item.status == "pending"
      return render json: { error: "Can only remove pending items" }, status: :unprocessable_entity
    end
    order = item.order
    item.destroy!
    order.recalculate_total!
    render json: { success: true, order: order.reload, items: order.order_items }
  end
end
