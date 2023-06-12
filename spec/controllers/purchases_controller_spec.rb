require 'rails_helper'

describe PurchasesController, type: :controller do
  render_views

  let!(:buyer) { create :user }
  let!(:vendor) { create :user }
  let!(:product) { create :product, user: vendor, title: ":product-title:" }
  let!(:purchase) { create_purchase_from_products_and_user([product], buyer) }

  before { sign_in buyer }

  describe "#index" do
    it "lists the buyer's purchases" do
      get :index

      expect(response).to render_template(:index)
      expect(response.body).to include(purchase_path(purchase))
    end
  end

  describe "#show" do
    it "shows a successful purchase" do
      get :show, params: { id: purchase.id }

      expect(response).to render_template(:show)
      expect(response.body).to include(":product-title:")
    end

    it "shows a failed purchase" do
      failed_purchase = create_purchase_from_products_and_user([product], buyer, failed: true)

      get :show, params: { id: failed_purchase.id }

      expect(response).to render_template(:show)
      expect(response.body).to include("not charged due to system or vendor error")
    end
  end
end
