class OrderChannel < ApplicationCable::Channel
  def subscribed
    order = Order.find(params[:id])
    stream_for order
  end
end
