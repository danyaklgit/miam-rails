class Api::ReservationsController < Api::BaseController
  def update_status
    reservation = Reservation.find(params[:id])
    reservation.update!(status: params[:status])
    render json: { success: true, reservation: reservation }
  end

  def destroy
    reservation = Reservation.find(params[:id])
    reservation.update!(status: "cancelled")
    render json: { success: true }
  end
end
