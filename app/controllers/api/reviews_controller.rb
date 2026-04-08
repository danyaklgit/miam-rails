class Api::ReviewsController < Api::BaseController
  def index
    reviews = Review.where(restaurant_id: params[:restaurant_id]).order(created_at: :desc)
    render json: reviews
  end

  def create
    review = Review.new(
      restaurant_id: params[:restaurant_id],
      order_id: params[:order_id],
      rating: params[:rating],
      feedback: params[:feedback],
      redirected_to_google: params[:redirected_to_google] || false
    )

    if review.save
      render json: { success: true, id: review.id }
    else
      render json: { error: review.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end
end
