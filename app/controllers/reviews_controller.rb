class ReviewsController < ApplicationController
  before_action :product_params, only: [:new, :create]
  def new
    @review = Review.new
  end

  def create
    @review = Review.new(set_review)
    @review.product = @product
    @review.user = current_user
    if @review.save
      redirect_to product_path(@product)
    else
      render :new
    end
  end

  private

  def product_params
    @product = helpers.load_product_to_review(params[:product_id])
  end

  def set_review
    params.require(:review).permit(:content, :rating)
  end
end
