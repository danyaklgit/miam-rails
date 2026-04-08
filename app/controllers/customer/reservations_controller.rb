class Customer::ReservationsController < Customer::BaseController
  def new
  end

  def create
    @reservation = @restaurant.reservations.new(
      date: params[:date],
      time: params[:time],
      party_size: params[:party_size],
      customer_name: params[:customer_name],
      customer_phone: params[:customer_phone],
      customer_email: params[:customer_email],
      notes: params[:notes],
      status: "confirmed"
    )

    if @reservation.save
      redirect_to "/#{@restaurant.slug}/reserve/confirmation/#{@reservation.id}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
    @reservation = @restaurant.reservations.find(params[:id])
  end
end
