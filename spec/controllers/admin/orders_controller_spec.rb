require 'rails_helper'

describe Admin::OrdersController do
  render_views

  let!(:admin) { create :admin }
  before { sign_in admin }

  describe "#index" do
    it "renders the index page" do
      order = create :order

      get :index

      expect(response).to render_template(:index)
      expect(response.body).to include(order.id)
    end
  end
end
