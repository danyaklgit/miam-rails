class Dashboard::OffersController < Dashboard::BaseController
  def index
    @offers = @restaurant.offers.order(created_at: :desc)
  end

  def new
    @offer = @restaurant.offers.new
  end

  def create
    @offer = @restaurant.offers.new(offer_params)
    if @offer.save
      redirect_to dashboard_offers_path, notice: "Offer created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @offer = @restaurant.offers.find(params[:id])
  end

  def update
    @offer = @restaurant.offers.find(params[:id])
    if @offer.update(offer_params)
      redirect_to dashboard_offers_path, notice: "Offer updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @restaurant.offers.find(params[:id]).destroy!
    redirect_to dashboard_offers_path, notice: "Offer deleted."
  end

  private

  def offer_params
    params.require(:offer).permit(:type, :name, :value, :promo_code, :active, :max_redemptions, :min_order_amount)
  end
end
