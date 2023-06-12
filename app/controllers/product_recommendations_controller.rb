class ProductRecommendationsController < ApplicationController
  after_action :verify_authorized

  def new
    @product = Product.find(params[:product_id])
    authorize @product, :recommend?

    @already_recommended_users = ProductRecommendation
      .where(product: @product, recommended_by_user: current_user)
      .includes(:recommended_to_user)
      .map(&:recommended_to_user)
    @users = User.all - @already_recommended_users - [current_user]
    @body_classes = "bg-light"
  end

  def save
    @product = Product.find(params[:product_id])
    authorize @product, :recommend?

    recommended_to_user = User.find(params[:recommended_to_user_id])

    ProductRecommendation.create!(
      product: @product,
      recommended_by_user: current_user,
      recommended_to_user: recommended_to_user
    )

    current_user.decrement!(:remaining_product_recommendations)

    MessageMailer.product_recommended(
      product: @product,
      recommended_by_user: current_user,
      recommended_to_user: recommended_to_user
    ).deliver_now

    redirect_to helpers.user_with_product_tab_path(@product), flash: {
      notice: "Successfully recommended #{@product.title}"
    }
  end
end
