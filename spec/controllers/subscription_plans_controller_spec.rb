require 'rails_helper'

describe SubscriptionPlansController do
  render_views

  let!(:premium_plan) { create :subscription_product, subscription_access_level: "premium", state: "published" }
  let!(:platinum_plan) { create :subscription_product, subscription_access_level: "platinum", state: "published" }
  let!(:partner_plan) { create :subscription_product, subscription_access_level: "partner", state: "published" }

  describe "#index" do
    it "renders the plans" do
      get :index

      expect(response).to render_template(:index)
    end
  end
end
