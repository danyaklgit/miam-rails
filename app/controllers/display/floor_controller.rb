class Display::FloorController < Display::BaseController
  def show
    @tables = @restaurant.restaurant_tables.order(:number).map do |table|
      session = table.dining_sessions.active.last
      order = session&.order
      items = order&.order_items || []
      members = session&.session_members || []

      {
        table: table,
        session: session,
        order: order,
        items: items,
        members: members,
        item_counts: {
          ordered: items.count { |i| i.status == "ordered" },
          preparing: items.count { |i| i.status == "preparing" },
          ready: items.count { |i| i.status == "ready" }
        }
      }
    end
  end
end
