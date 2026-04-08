class Api::CustomerAddressesController < Api::BaseController
  def index
    addresses = CustomerAddress.where(user_id: current_user_id)
    render json: addresses
  end

  def create
    address = CustomerAddress.new(address_params.merge(user_id: current_user_id))
    if address.is_default
      CustomerAddress.where(user_id: current_user_id).update_all(is_default: false)
    end
    if address.save
      render json: address, status: :created
    else
      render json: { error: address.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  def update
    address = CustomerAddress.find_by!(id: params[:id], user_id: current_user_id)
    if params[:customer_address][:is_default]
      CustomerAddress.where(user_id: current_user_id).update_all(is_default: false)
    end
    address.update!(address_params)
    render json: address
  end

  def destroy
    address = CustomerAddress.find_by!(id: params[:id], user_id: current_user_id)
    address.destroy!
    render json: { success: true }
  end

  private

  def current_user_id
    current_user&.id || session[:device_id] || "anonymous"
  end

  def address_params
    params.require(:customer_address).permit(:label, :street, :city, :postal_code, :country, :instructions, :is_default, :restaurant_id)
  end
end
