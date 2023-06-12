class OrdersController < ApplicationController
  after_action :verify_authorized

  def index
    authorize Order

    @orders = current_user.orders.charged.order(created_at: :desc)
  end

  def show
    @order = Order.find(params[:id])

    authorize @order
  end

  # for debugging by admins/developers only
  def invoice
    @order = Order.find(params[:id])
    authorize @order

    render partial: "invoice", locals: { order: @order }, layout: false
  end
end
