class ProductCategoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @category = ProductCategory.find(params[:id])
    layout = user_signed_in? ? "application" : "front"
    @wrapper = true
    render :show, layout: layout
  end
end
