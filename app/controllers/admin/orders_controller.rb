class Admin::OrdersController < AdminController
  after_action :verify_authorized

  def index
    authorize Order

    @body_classes = 'page-wide'

    @filterrific = initialize_filterrific(
      Order,
      params[:filterrific],
      sanitize_params: true
    ) || return

    @orders = @filterrific
      .find
      .paginate(page: params[:page], per_page: 25)
  end
end
