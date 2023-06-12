require 'rails_helper'

describe StripeCustomerRetriever, vcr: true do
  describe '#call' do
    it "creates a new customer if there is no existing one" do
      target_account = create(:user)
      create(:profile, provider: 'stripe_connect', user: target_account, uid: "acct_1J2zDlImLCgNPewX")
      user_to_create = create(:user, email: "newcustomer@example.com")

      expect(Stripe::Customer).to receive(:create).and_call_original

      customer = StripeCustomerRetriever.new(target_account: target_account, user_to_create: user_to_create).call

      expect(customer.email).to eq("newcustomer@example.com")
    end

    it "returns an existing customer" do
      target_account = create(:user)
      create(:profile, provider: 'stripe_connect', user: target_account, uid: "acct_1J2zDlImLCgNPewX")
      user_to_create = create(:user, email: "testuser@example.com")

      expect(Stripe::Customer).to_not receive(:create)

      customer = StripeCustomerRetriever.new(target_account: target_account, user_to_create: user_to_create).call

      expect(customer.email).to eq("testuser@example.com")
    end
  end
end
