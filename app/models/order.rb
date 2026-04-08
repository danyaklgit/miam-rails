class Order < ApplicationRecord
  self.inheritance_column = nil # disable STI — "type" is dineIn/takeaway/delivery

  belongs_to :restaurant
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_one :review, dependent: :destroy

  validates :type, presence: true, inclusion: { in: %w[dineIn takeaway delivery] }
  validates :status, inclusion: { in: %w[pending confirmed preparing ready outForDelivery completed cancelled] }

  scope :pending, -> { where(status: "pending") }
  scope :active, -> { where(status: %w[pending confirmed preparing ready outForDelivery]) }
  scope :completed, -> { where(status: "completed") }

  after_commit :broadcast_updates, on: [:create, :update]

  # Recalculate total from order items
  def recalculate_total!
    total = order_items.sum { |i| (i.price.to_f + (i.variant_price_modifier || 0).to_f) * (i.quantity || 1) }
    update_column(:total_amount, total)
  end

  # Auto-sync order status based on item statuses (ported from Express offerEngine)
  def sync_status_from_items!
    items = order_items.reload
    return if items.empty?

    statuses = items.map(&:status)

    if self.type == "dineIn"
      # Full auto-sync for dine-in
      if statuses.all? { |s| s == "served" }
        update!(status: "completed") unless status == "completed"
      elsif statuses.all? { |s| s.in?(%w[ready served]) }
        update!(status: "ready") unless status.in?(%w[ready completed])
      elsif statuses.any? { |s| s == "preparing" }
        update!(status: "preparing") unless status.in?(%w[preparing ready completed])
      elsif statuses.any? { |s| s == "ordered" } && status == "pending"
        update!(status: "confirmed")
      end
    else
      # Takeaway/delivery: only auto-advance to "preparing"
      if statuses.any? { |s| s == "preparing" } && status == "confirmed"
        update!(status: "preparing")
      end
    end
  end

  private

  def broadcast_updates
    # Broadcast to customer table page — replace the cart FAB with updated state
    # The FAB and drawer are server-rendered, so we signal a refresh
    Turbo::StreamsChannel.broadcast_replace_to(
      "order_#{id}",
      target: "order_status_signal",
      html: "<div id=\"order_status_signal\" data-status=\"#{status}\" data-total=\"#{total_amount}\" data-paid=\"#{paid_amount}\" data-ts=\"#{Time.current.to_i}\"></div>"
    )
  rescue => e
    Rails.logger.debug("Order broadcast skipped: #{e.message}")
  end
end
