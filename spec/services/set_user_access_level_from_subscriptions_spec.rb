require 'rails_helper'

describe SetUserAccessLevelFromSubscriptions do
  describe ".call" do
    it "sets a freemium user to a subscribed access level when their subscription starts", vcr: true do
      create :product, stripe_price_id: Rails.application.config.test_premium_subscription_price_id, subscription_access_level: "premium"
      user = create :user, access_level: "freemium"
      assign_customer_with_active_subscription(user)

      SetUserAccessLevelFromSubscriptions.call(user.stripe_customer_id)

      expect(user.reload.access_level).to eq("premium")
    end

    it "sets a user with a subscribed access level to 'freemium' when their subscription ends", vcr: true do
      user = create :user, access_level: "premium"
      assign_customer_without_active_subscription(user)

      SetUserAccessLevelFromSubscriptions.call(user.stripe_customer_id)

      expect(user.reload.access_level).to eq("freemium")
    end

    it "excludes admins" do
      create :user, access_level: "admin", stripe_customer_id: ":customer-id:"
      expect(SetUserAccessLevelFromSubscriptions).to_not receive(:set_user_access_level)
      SetUserAccessLevelFromSubscriptions.call(":customer-id:")
    end

    it "excludes partners" do
      create :user, access_level: "partner", stripe_customer_id: ":customer-id:"
      expect(SetUserAccessLevelFromSubscriptions).to_not receive(:set_user_access_level)
      SetUserAccessLevelFromSubscriptions.call(":customer-id:")
    end

    it "doesn't raise an error when the user isn't present" do
      expect(SetUserAccessLevelFromSubscriptions).to_not receive(:set_user_access_level)
      expect {
        SetUserAccessLevelFromSubscriptions.call(":customer-id:")
      }.to_not raise_error
    end
  end
end
