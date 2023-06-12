require 'rails_helper'

describe ServiceplacesController do
  render_views

  let!(:user) { create :user }
  let!(:category) { create :product_category, title: "Some category" }

  describe "#show" do
    it "renders the show page to a logged in user" do
      sign_in user

      create :product, title: "Some title", categories: [category]

      get :show

      expect(response).to render_template(:show)
      expect(response.body).to include("Some title")
      expect(response.body).to include("Some category")
    end

    it "renders the show page to a logged out user" do
      create :product, title: "Some title", categories: [category]

      get :show

      expect(response).to render_template(:show)
      expect(response.body).to include("Some title")
      expect(response.body).to include("Some category")
    end
  end
end
