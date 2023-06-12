require 'rails_helper'

describe ProductRecommendationsController, type: :controller do
  include ProductPathHelper
  render_views

  describe "#new" do
    let!(:product) { create :product }
    let!(:user) { create :user }
    let!(:recommending_to) { create :user, first_name: "RecommendingTo" }
    let!(:already_recommended) { create :user, first_name: "AlreadyRecommended" }
    let!(:existing_recommendation) { create :product_recommendation, product: product, recommended_by_user: user, recommended_to_user: already_recommended }

    before { sign_in user }

    it "renders a form for a new product recommendation" do
      get :new, params: { product_id: product.id }

      expect(response).to render_template(:new)
      expect(response.body).to include("RecommendingTo")
      expect(response.body).to_not include("AlreadyRecommended")
    end
  end

  describe "#save" do
    let!(:product) { create :product }
    let!(:user) { create :user, remaining_product_recommendations: 5 }
    let!(:recommending_to) { create :user }

    before { sign_in user }

    it "creates a new product recommendation" do
      expect(MessageMailer).to receive(:product_recommended).with(
        product: product,
        recommended_by_user: user,
        recommended_to_user: recommending_to
      ).and_call_original

      get :save, params: { product_id: product.id, recommended_to_user_id: recommending_to.id }

      recommendation = ProductRecommendation.last
      expect(recommendation.recommended_by_user).to eq(user)
      expect(recommendation.recommended_to_user).to eq(recommending_to)
      expect(recommendation.product).to eq(product)

      expect(user.reload.remaining_product_recommendations).to eq(4)

      expect(response).to redirect_to(user_with_product_tab_path(product))
    end
  end
end
