class OrderItem < ApplicationRecord
  self.inheritance_column = nil # disable STI — "type" is food/drink

  belongs_to :order

  validates :name, presence: true, length: { maximum: 255 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :ordered_by, presence: true
  validates :type, presence: true, inclusion: { in: %w[food drink] }
  validates :status, inclusion: { in: %w[pending ordered preparing ready served] }

  scope :food, -> { where(type: "food") }
  scope :drinks, -> { where(type: "drink") }
  scope :pending, -> { where(status: "pending") }
  scope :confirmed, -> { where.not(status: "pending") }
  scope :by_status, ->(status) { where(status: status) }

  after_commit :broadcast_on_create, on: :create
  after_commit :broadcast_on_update, on: :update
  after_commit :sync_order_status, on: :update

  def sync_order_status
    order.sync_status_from_items!
  end

  private

  def broadcast_on_create
    # Only show in display when sent to kitchen (not pending)
    return if status == "pending"

    # Append new ticket to kitchen/bar display
    Turbo::StreamsChannel.broadcast_append_to(
      "restaurant_#{order.restaurant_id}",
      target: "ticket_grid",
      partial: "display/shared/order_ticket",
      locals: { item: self, show_table: true }
    )
  rescue ActionView::MissingTemplate
    nil
  ensure
    # Append to customer table page order list
    broadcast_order_append
    # Notify all table page users (even those without an order subscription yet)
    broadcast_table_refresh
  end

  def broadcast_on_update
    if status == "served"
      # Remove from display
      Turbo::StreamsChannel.broadcast_remove_to(
        "restaurant_#{order.restaurant_id}",
        target: "ticket_#{id}"
      )
    elsif status_previously_was == "pending" && status == "ordered"
      # Item just confirmed — append to display (didn't exist there before)
      Turbo::StreamsChannel.broadcast_append_to(
        "restaurant_#{order.restaurant_id}",
        target: "ticket_grid",
        partial: "display/shared/order_ticket",
        locals: { item: self, show_table: true }
      )
    else
      # Replace existing ticket on display
      Turbo::StreamsChannel.broadcast_replace_to(
        "restaurant_#{order.restaurant_id}",
        target: "ticket_#{id}",
        partial: "display/shared/order_ticket",
        locals: { item: self, show_table: true }
      )
    end
  rescue ActionView::MissingTemplate
    nil
  ensure
    # Replace on customer table page
    broadcast_order_replace
  end

  def broadcast_order_append
    Turbo::StreamsChannel.broadcast_append_to(
      "order_#{order_id}",
      target: "order_items_list",
      partial: "customer/tables/order_item",
      locals: { item: self, theme: order.restaurant.theme || {} }
    )
  rescue ActionView::MissingTemplate
    nil
  end

  def broadcast_order_replace
    Turbo::StreamsChannel.broadcast_replace_to(
      "order_#{order_id}",
      target: "order_item_#{id}",
      partial: "customer/tables/order_item",
      locals: { item: self, theme: order.restaurant.theme || {} }
    )
  rescue ActionView::MissingTemplate
    nil
  end

  # Broadcast to the table stream so all table page users refresh
  # (needed when users loaded the page before the order existed)
  def broadcast_table_refresh
    table = DiningSession.find_by(id: order.session_id)&.restaurant_table
    return unless table

    Turbo::StreamsChannel.broadcast_replace_to(
      "table_#{table.id}",
      target: "table_refresh_signal",
      html: "<div id=\"table_refresh_signal\" data-ts=\"#{Time.current.to_i}\"></div>"
    )
  rescue => e
    Rails.logger.debug("Table broadcast skipped: #{e.message}")
  end
end
