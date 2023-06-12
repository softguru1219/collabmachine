class Admin::ProductsController < AdminController
  after_action :verify_authorized

  def index
    authorize Product

    @body_classes = 'page-wide'

    @filterrific = initialize_filterrific(
      Product.translated_columns,
      params[:filterrific],
      sanitize_params: true
    ) || return

    @products = @filterrific
      .find
      .includes(:user)
      .paginate(page: params[:page], per_page: 25)
  end

  def show
    @product = Product.find(params[:id])
    authorize @product
  end
end
