class Payment < ApplicationRecord
  belongs_to :order

  validates :user_id, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[pending processing succeeded failed refunded] }

  after_commit :broadcast_to_order, on: [:create, :update]

  private

  def broadcast_to_order
    Turbo::StreamsChannel.broadcast_replace_to(
      "order_#{order_id}",
      target: "payment_progress",
      partial: "customer/tables/payment_progress",
      locals: { order: order.reload }
    )
  rescue ActionView::MissingTemplate
    # Partial not yet created — skip broadcast
  end
end
