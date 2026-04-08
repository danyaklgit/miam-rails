class Customer::ReceiptsController < Customer::BaseController
  def show
    @order = Order.find(params[:order_id])
    @order_items = @order.order_items
    @payments = @order.payments.where(status: "succeeded")
    @paid_amount = @payments.sum(:amount)
    @tip_total = @payments.sum(:tip_amount)
    @review = @order.review
  end
end
