class Display::HostessController < Display::BaseController
  def show
    @date = params[:date] || Date.current.to_s
    @reservations = @restaurant.reservations
      .where(date: @date)
      .order(:time)

    @tab = params[:tab] || "upcoming"
    @filtered = case @tab
    when "upcoming" then @reservations.where(status: %w[pending confirmed])
    when "seated" then @reservations.where(status: "seated")
    when "past" then @reservations.where(status: %w[completed cancelled noShow])
    else @reservations
    end

    @stats = {
      upcoming: @reservations.where(status: %w[pending confirmed]).count,
      seated: @reservations.where(status: "seated").count,
      expected_guests: @reservations.where(status: %w[pending confirmed seated]).sum(:party_size),
      next_reservation: @reservations.where(status: %w[pending confirmed]).order(:time).first
    }
  end
end
