class Dashboard::ReservationsController < Dashboard::BaseController
  def index
    @date = params[:date] || Date.current.to_s
    @reservations = @restaurant.reservations.where(date: @date).order(:time)
  end

  def update
    reservation = @restaurant.reservations.find(params[:id])
    reservation.update!(status: params[:status])
    redirect_to dashboard_reservations_path(date: reservation.date), notice: "Reservation updated."
  end

  def destroy
    reservation = @restaurant.reservations.find(params[:id])
    reservation.destroy!
    redirect_to dashboard_reservations_path, notice: "Reservation deleted."
  end
end
