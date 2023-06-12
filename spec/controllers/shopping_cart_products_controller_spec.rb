require 'rails_helper'

describe ShoppingCartProductsController, type: :controller do
  render_views

  let!(:user) { create :user }
  let!(:product) { create :product }

  before { sign_in user }

  describe "#create" do
    it "adds the product to the cart" do
      post :create, params: { product_id: product.id }, format: :json

      data = JSON.parse(response.body)
      expect(data["products"][0]["id"]).to eq(product.id)
    end
  end

  describe "#destroy" do
    it "removes the product from the cart" do
      session[:shopping_cart] = { product_ids: [product.id] }

      delete :destroy, params: { id: product.id }

      data = JSON.parse(response.body)
      expect(data["products"][0]).to eq(nil)
    end
  end
end
