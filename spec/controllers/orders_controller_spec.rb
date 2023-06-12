require 'rails_helper'

describe OrdersController, type: :controller do
  render_views

  let!(:buyer) { create :user }
  let!(:vendor) { create :user }
  let!(:product) { create :product, user: vendor, title: ":product-title:" }
  let!(:purchase) { create_purchase_from_products_and_user([product], buyer) }
  let!(:order) { purchase.orders.first }

  before { sign_in vendor }

  describe "#index" do
    it "lists sold orders" do
      get :index

      expect(response).to render_template(:index)
      expect(response.body).to include(order_path(order))
    end
  end

  describe "#show" do
    it "shows the order" do
      get :show, params: { id: order.id }

      expect(response).to render_template(:show)
      expect(response.body).to include(":product-title:")
    end
  end
end
