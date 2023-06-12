class ShoppingCartProductsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create, :destroy]

  def create
    product = Product.find(params[:product_id])
    authorize product, :buy?

    render json: ShoppingCart.add_product(session, params[:product_id])
  end

  def destroy
    render json: ShoppingCart.remove_product(session, params[:id])
  end
end
