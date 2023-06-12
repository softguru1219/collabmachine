require 'rails_helper'

describe Admin::ProductsController do
  render_views

  let!(:admin) { create :admin }
  before { sign_in admin }

  describe "#index" do
    it "renders the index page" do
      create :product, title: "Some title"

      get :index

      expect(response).to render_template(:index)
      expect(response.body).to include("Some title")
    end
  end

  describe "#show" do
    it "renders the show page" do
      product = create :product, title: "Some title"

      get :show, params: { id: product.id }

      expect(response).to render_template(:show)
      expect(response.body).to include("Some title")
    end
  end
end
