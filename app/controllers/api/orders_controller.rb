class Api::OrdersController < Api::BaseController
  def show
    order = Order.find(params[:id])
    render json: {
      order: order,
      items: order.order_items,
      payments: order.payments
    }
  end

  def create
    order = Order.new(order_params)
    if order.save
      render json: { success: true, id: order.id }
    else
      render json: { error: order.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def add_items
    order = Order.find(params[:id])
    items = params[:items] || []
    created = items.map do |item_data|
      order.order_items.create!(
        menu_item_id: item_data[:menu_item_id],
        name: item_data[:name],
        price: item_data[:price],
        quantity: item_data[:quantity] || 1,
        notes: item_data[:notes] || "",
        type: item_data[:type] || "food",
        variant_id: item_data[:variant_id],
        variant_name: item_data[:variant_name],
        variant_price_modifier: item_data[:variant_price_modifier] || 0,
        ordered_by: item_data[:ordered_by] || session[:device_id] || SecureRandom.uuid,
        status: "pending"
      )
    end
    order.recalculate_total!
    render json: { success: true, items: created.map(&:id) }
  end

  # Convert pending items to ordered (dine-in "send to kitchen")
  def confirm
    order = Order.find(params[:id])
    # Update each item individually so after_commit broadcasts fire
    order.order_items.pending.find_each { |item| item.update!(status: "ordered") }
    order.update!(status: "confirmed") if order.status == "pending"
    order.recalculate_total!
    render json: { success: true, order: order, items: order.order_items.reload }
  end

  def claim_items
    order = Order.find(params[:id])
    item_ids = params[:item_ids] || []
    user_id = params[:user_id] || session[:device_id]
    order.order_items.where(id: item_ids).update_all(claimed_by: user_id)
    render json: { success: true }
  end

  def update_status
    order = Order.find(params[:id])
    order.update!(status: params[:status])
    render json: { success: true, id: order.id, status: order.status }
  end

  # Record payment (simulated — real Stripe in payments#create)
  def pay
    order = Order.find(params[:id])
    amount = params[:amount].to_f
    tip_amount = params[:tip_amount].to_f
    device_id = params[:deviceId] || session[:device_id] || "anonymous"

    payment = order.payments.create!(
      user_id: device_id,
      amount: amount,
      tip_amount: tip_amount,
      stripe_payment_intent_id: "sim_#{Time.current.to_i}",
      status: "succeeded",
      method: "card"
    )

    # Mark items as paid if split by items
    if params[:itemPayments].present?
      params[:itemPayments].each do |ip|
        item = order.order_items.find_by(id: ip[:id])
        next unless item
        if ip[:paidQuantity].to_i >= (item.quantity || 1)
          item.update!(paid_by: device_id)
        end
      end
    elsif params[:splitType] == "full"
      order.order_items.where(paid_by: nil).update_all(paid_by: device_id)
    end

    # Update order paid amount
    total_paid = order.payments.where(status: "succeeded").sum(:amount)
    total_tips = order.payments.where(status: "succeeded").sum(:tip_amount)
    order.update!(paid_amount: total_paid, tip_amount: total_tips)

    is_fully_paid = total_paid >= order.total_amount.to_f

    # If fully paid dine-in, close session
    if is_fully_paid && order.type == "dineIn" && order.session_id.present?
      session_record = DiningSession.find_by(id: order.session_id)
      if session_record
        session_record.update!(status: "closed", closed_at: Time.current)
        session_record.restaurant_table.update!(status: "available")
      end
    end

    render json: {
      payment: payment,
      order: order.reload,
      payments: order.payments,
      isFullyPaid: is_fully_paid
    }
  end

  private

  def order_params
    params.permit(:restaurant_id, :type, :status, :total_amount, :promo_code, :session_id, :table_id,
      customer_info: [:name, :email, :phone, :userId],
      delivery_address: [:street, :city, :postalCode, :country, :instructions])
  end
end
