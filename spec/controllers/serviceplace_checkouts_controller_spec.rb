require 'rails_helper'

describe ServiceplaceCheckoutsController, type: :controller do
  render_views

  let!(:buyer) { create :user }
  let!(:vendor) { create :user }
  let!(:product) { create :product, user: vendor, price: 100, title: ":product-title:" }

  before { sign_in buyer }
  before { request.session[:shopping_cart] = { product_ids: [product.id] } }
  before { assign_customer_with_source(buyer) }

  describe "#show" do
    it "redirects to the confirm_payment_information page when the user is signed in" do
      get :show

      expect(response).to redirect_to(confirm_payment_information_serviceplace_checkout_path)
    end

    it "redirects to the sign up path when the user is not signed in" do
      sign_out buyer

      get :show

      expect(response).to redirect_to(new_user_registration_path)
    end
  end

  describe "#confirm_payment_information", vcr: true do
    it "renders the page when the user does not yet have a card", vcr: true do
      assign_customer_without_source(buyer)

      get :confirm_payment_information

      expect(response).to render_template(:confirm_payment_information)
    end

    it "renders the page when the user already has a card", vcr: true do
      get :confirm_payment_information

      expect(response).to render_template(:confirm_payment_information)
    end
  end

  describe "#update_card" do
    it "updates the user's card", vcr: true do
      patch :update_card, params: { stripe_card_token: "tok_mastercard" }

      expect(response.status).to eq(200)
    end
  end

  describe "#confirm_purchase" do
    it "allows the user to review their cart before purchasing" do
      get :confirm_purchase

      expect(response).to render_template(:confirm_purchase)
    end
  end

  describe "#do_confirm_purchase" do
    before { vendor.setup_with_test_stripe_connect }

    it "creates the order and redirects to the order path when a valid checksum is given", vcr: true do
      post :do_confirm_purchase, params: { checksum: ShoppingCart.fetch_from_session(request.session).checksum }

      purchase = Purchase.last
      expect(purchase.state).to eq("processed")
      expect(ShoppingCart.fetch_from_session(session).products).to eq([])

      expect(response).to redirect_to(view_invoice_serviceplace_checkout_path(purchase_id: purchase.id))
    end

    it "redirects to the confirm purchase page when the checksum doesn't match the saved cart" do
      post :do_confirm_purchase, params: { checksum: "invalid" }

      expect(response).to redirect_to(confirm_purchase_serviceplace_checkout_path)
    end

    it "redirects to the user edit path if the user doesn't have their full name" do
      buyer.update_columns(first_name: nil, last_name: nil)

      post :do_confirm_purchase, params: { checksum: ShoppingCart.fetch_from_session(request.session).checksum }

      expect(response).to redirect_to(edit_user_path(buyer))
    end
  end

  describe "#view_invoice" do
    it "shows the user their invoice for a successful purchase" do
      purchase = create_purchase_from_products_and_user([product], buyer)

      get :view_invoice, params: { purchase_id: purchase.id }
      expect(response).to render_template(:view_invoice)
      expect(response.body).to include(":product-title:")
    end

    it "shows the user their invoice for a failed purchase" do
      purchase = create_purchase_from_products_and_user([product], buyer, failed: true)

      get :view_invoice, params: { purchase_id: purchase.id }
      expect(response).to render_template(:view_invoice)
      expect(response.body).to include("not charged due to system or vendor error")
    end
  end
end
