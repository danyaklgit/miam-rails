class Dashboard::FloorController < Dashboard::BaseController
  def index
    @tables = @restaurant.restaurant_tables.order(:number).map do |table|
      session = table.dining_sessions.active.last
      { table: table, session: session, order: session&.order, members: session&.session_members || [] }
    end
  end
end
