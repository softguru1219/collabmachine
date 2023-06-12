require 'rails_helper'

describe CheckoutController do
  render_views

  let!(:user) { create :user }
  before { sign_in user }

  describe "#create" do
    it "creates a stripe checkout session" do
      session = double("session")
      expect(Stripe::Checkout::Session).to receive(:create).and_return(session)
      expect(session).to receive(:id).and_return("1")

      post :create, format: :js

      expect(response).to render_template(:create)
    end
  end

  describe "#cancel" do
    it "redirects to the randomly page" do
      get :cancel

      expect(response).to redirect_to(randomly_path)
    end
  end

  describe "#success" do
    it "renders the success message" do
      get :success

      expect(response).to render_template(:success)
    end
  end
end
