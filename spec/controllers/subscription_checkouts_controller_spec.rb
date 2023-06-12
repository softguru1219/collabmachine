require 'rails_helper'

describe SubscriptionCheckoutsController do
  render_views

  let!(:user) { create :user, access_level: "freemium" }
  before { assign_customer_without_active_subscription(user) }
  before { sign_in user }

  let!(:product) {
    create :product,
           stripe_price_id: Rails.application.config.test_premium_subscription_price_id,
           subscription_access_level: "premium"
  }

  describe "#new" do
    it "creates a new checkout session", vcr: true do
      expect(Stripe::Checkout::Session).to receive(:create).and_call_original

      get :new, params: { product_id: product.id }

      expect(response.status).to eq(302)
      expect(response.redirect_url).to include("checkout.stripe.com")
    end

    it "redirects if already subscribed" do
      user.update!(access_level: "premium")
      expect(Stripe::Checkout::Session).to_not receive(:create)

      get :new, params: { product_id: product.id }

      expect(response).to redirect_to(new_stripe_customer_portal_session_path)
    end

    it "redirects if not signed in" do
      sign_out user

      expect(Stripe::Checkout::Session).to_not receive(:create)

      get :new, params: { product_id: product.id }

      expect(response).to redirect_to(new_user_registration_path)
    end
  end

  describe "#success" do
    it "upgrades the user's access_level", vcr: true do
      assign_customer_with_active_subscription(user)

      get :success

      expect(user.reload.access_level).to eq("premium")
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "#cancel" do
    it "redirects to the dashboard path" do
      get :cancel
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
