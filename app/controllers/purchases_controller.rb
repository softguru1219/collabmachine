class PurchasesController < ApplicationController
  after_action :verify_authorized

  def index
    authorize Purchase

    @purchases = current_user.purchases.order(created_at: :desc)
  end

  def show
    @purchase = Purchase.includes(orders: :order_lines).find(params[:id])
    authorize @purchase
  end
end
