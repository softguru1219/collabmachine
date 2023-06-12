class ServiceplacesController < ApplicationController
  # can't eager load category products when also using `limit`
  skip_before_action :authenticate_user!, only: [:show]
  around_action :skip_bullet, only: [:show]

  def show
    @categories = ProductCategory.all

    layout = current_user.present? ? "application" : "front"
    @wrapper = true
    render :show, layout: layout
  end
end
