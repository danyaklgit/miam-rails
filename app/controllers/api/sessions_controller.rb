class Api::SessionsController < Api::BaseController
  def join
    restaurant = Restaurant.find(params[:restaurant_id])
    table = restaurant.restaurant_tables.find_by!(number: params[:table_number])

    session_record = table.dining_sessions.active.last
    unless session_record
      session_record = table.dining_sessions.create!(restaurant: restaurant, status: "active")
      table.update!(status: "occupied")
    end

    user_id = params[:user_id] || session[:device_id] || SecureRandom.uuid
    display_name = params[:display_name] || "Guest"

    member = session_record.session_members.find_or_create_by!(user_id: user_id) do |m|
      m.display_name = display_name
    end

    render json: {
      session_id: session_record.id,
      member_id: member.id,
      order_id: session_record.order_id,
      members: session_record.session_members.map { |m| { id: m.id, user_id: m.user_id, display_name: m.display_name } }
    }
  end

  def close
    session_record = DiningSession.find(params[:id])
    session_record.update!(status: "closed", closed_at: Time.current)
    session_record.restaurant_table.update!(status: "available")
    render json: { success: true }
  end
end
