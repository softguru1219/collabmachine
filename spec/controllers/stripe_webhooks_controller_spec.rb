require 'rails_helper'

describe StripeWebhooksController do
  render_views

  let!(:user) { create :user, access_level: "premium" }
  before { assign_customer_without_active_subscription(user) }

  let!(:valid_params) {
    {
      "stripe_webhook" => {
        "type" => "customer.subscription.created"
      },
      "data" => {
        "object" => {
          "customer" => user.stripe_customer_id
        }
      }
    }
  }

  describe "#create" do
    it "downgrades a user whose subscription has expired", vcr: true do
      expect(SetUserAccessLevelFromSubscriptions).to receive(:call).and_call_original

      post :create, params: valid_params.merge("secret" => "test_stripe_webhook_secret")

      expect(response.status).to eq(200)
      expect(user.reload.access_level).to eq("freemium")
    end

    it "raises an error when an invalid secret is passed" do
      expect(SetUserAccessLevelFromSubscriptions).to_not receive(:call)

      post :create, params: valid_params.merge("secret" => "invalid_secret")

      expect(response.status).to eq(403)
    end
  end
end
