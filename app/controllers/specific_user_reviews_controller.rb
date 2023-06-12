class SpecificUserReviewsController < ApplicationController
  before_action :find_product, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :find_specific_user, only: [:edit, :update, :destroy]
  def new
    @specific_user_rev = SpecificUserReview.new
  end

  def index
    @specific_user_revs = @product.specific_user_reviews
  end

  def create
    @specific_user_rev = SpecificUserReview.new(set_specific_user)
    @specific_user_rev.product = @product
    if @specific_user_rev.save
      redirect_to product_path(@product)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @specific_user_rev.update(set_specific_user)
    if @specific_user_rev.save
      redirect_to product_specific_user_reviews_path
    else
      render :edit
    end
  end

  def destroy
    if @specific_user_rev.destroy
      redirect_to product_specific_user_reviews_path
    else
      render :index
    end
  end

  private

  def find_product
    @product = helpers.load_product_to_review(params[:product_id])
  end

  def find_specific_user
    @specific_user_rev = SpecificUserReview.find(params[:id])
  end

  def set_specific_user
    params.require(:specific_user_review).permit(:specific_user_email)
  end
end
