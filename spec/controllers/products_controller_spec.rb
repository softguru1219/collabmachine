require 'rails_helper'

describe ProductsController do
  include ProductPathHelper

  render_views

  let!(:user) { create :user }
  let!(:profile) { create :profile, user: user, provider: 'stripe_connect' }
  before { sign_in user }

  let!(:category) { create :product_category, title: "Some category" }
  let!(:tax) { create :tax, user: user }

  let!(:valid_params) {
    {
      "title_fr" => "french_title",
      "title_en" => "english_title",
      "price" => "125.0",
      "description_fr" => "french_description",
      "description_en" => "english_description",
      "intended_audience_fr" => "french_intended_audience",
      "intended_audience_en" => "english_intended_audience",
      "value_proposition_fr" => "french_value_proposition",
      "value_proposition_en" => "english_value_proposition",
      "agreed_to_manage_taxes" => "1",
      "category_ids" => ["", category.id.to_s],
      "tax_ids" => ["", tax.id.to_s],
      "delete_carousel_image_ids" => [],
      "stripe_price_id" => "",
      "subscription_access_level" => ""
    }
  }
  let!(:subscription_product_params) {
    valid_params.merge("stripe_price_id" => ":stripe-price-id:", "subscription_access_level" => "premium")
  }
  let!(:unbuyable_product_params) {
    valid_params.merge("buyable" => "0")
  }
  let!(:invalid_params) { valid_params.merge("price" => "") }

  describe "#index" do
    it "renders the index page" do
      [
        Product.states.published,
        Product.states.for_review,
        Product.states.archived,
        Product.states.rejected
      ].each_with_index { |state, index| create :product, state: state, user: user, title: "Product #{index}" }

      get :index

      expect(response).to render_template(:index)
      expect(response.body).to include("Product 1")
    end
  end

  describe "#new" do
    it "renders the new page" do
      get :new

      expect(response).to render_template(:new)
    end

    it "renders the new page when the user is an admin" do
      user.update!(access_level: User.access_levels.admin)

      get :new

      expect(response).to render_template(:new)
    end

    it "redirects to the stripe connect portal when the user does not have stripe connected" do
      user.profiles.delete_all

      get :new

      expect(response).to redirect_to(include("stripe"))
    end
  end

  describe "#create" do
    it "creates a product from valid params" do
      post :create, params: { product: valid_params }

      product = Product.last

      expect(product.title_fr).to eq("french_title")
      expect(product.title_en).to eq("english_title")
      expect(product.price).to eq(125.0)
      expect(product.description_fr).to eq("french_description")
      expect(product.description_en).to eq("english_description")
      expect(product.intended_audience_fr).to eq("french_intended_audience")
      expect(product.intended_audience_en).to eq("english_intended_audience")
      expect(product.value_proposition_fr).to eq("french_value_proposition")
      expect(product.value_proposition_en).to eq("english_value_proposition")
      expect(product.state).to eq("for_review")
      expect(product.categories).to eq([category])
      expect(product.taxes).to eq([tax])
      expect(product.stripe_price_id).to eq(nil)
      expect(product.subscription_access_level).to eq(nil)

      expect(response).to redirect_to(user_with_product_tab_path(product))
    end

    it "rerenders the form when invalid params are submitted" do
      expect {
        post :create, params: { product: invalid_params }
      }.to_not change(Product, :count)

      expect(response).to render_template(:new)
    end

    it "rerenders the form when the user doesn't agree to manage taxes" do
      params = valid_params.merge("agreed_to_manage_taxes" => "0")

      expect {
        post :create, params: { product: params }
      }.to_not change(Product, :count)

      expect(response).to render_template(:new)
    end

    it "redirects to the stripe connect portal when the user does not have stripe connected" do
      user.profiles.delete_all

      expect {
        post :create, params: { product: valid_params }
      }.to_not change(Product, :count)

      expect(response).to redirect_to(include("stripe"))
    end

    it "creates a subscription product when the user is an admin" do
      user.update!(access_level: User.access_levels.admin)

      post :create, params: { product: subscription_product_params }

      product = Product.last

      expect(product.stripe_price_id).to eq(":stripe-price-id:")
      expect(product.subscription_access_level).to eq("premium")
    end

    it "doesn't create a subscription product when the user is a normal user" do
      post :create, params: { product: subscription_product_params }

      product = Product.last

      expect(product.stripe_price_id).to eq(nil)
      expect(product.subscription_access_level).to eq(nil)
    end

    it "creates an unbuyable product when the user is an admin" do
      user.update!(access_level: User.access_levels.admin)

      post :create, params: { product: unbuyable_product_params }

      product = Product.last

      expect(product.buyable).to eq(false)
    end

    it "doesn't create an unbuyable product when the user is a normal user" do
      post :create, params: { product: unbuyable_product_params }

      product = Product.last

      expect(product.buyable).to eq(true)
    end
  end

  describe "#show" do
    it "renders the show page when the request passes embedded: true" do
      product = create :product, title: "Some title", categories: [category]

      get :show, params: { id: product.id, embedded: "true" }

      expect(response).to render_template("products/_show")
      expect(response.body).to include("Some title")
      expect(response.body).to include("Some category")
    end

    it "renders the show page when the user is logged in" do
      product = create :product, title: "Some title", categories: [category]

      get :show, params: { id: product.id }

      expect(response).to render_template(:show)
      expect(response.body).to include("Some title")
      expect(response.body).to include("Some category")
    end

    it "renders the show page when the user is not logged in" do
      sign_out user

      product = create :product, title: "Some title", categories: [category]

      get :show, params: { id: product.id }

      expect(response).to render_template(:show)
      expect(response.body).to include("Some title")
      expect(response.body).to include("Some category")
    end
  end

  describe "#edit" do
    it "renders the edit page" do
      product = create :product, categories: [category], user: user

      get :edit, params: { id: product.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "#update" do
    it "updates the product with valid params" do
      product = create :product, title_en: "original_title", user: user
      valid_params["title_en"] = "updated_title"

      patch :update, params: { id: product.id, product: valid_params }

      expect(product.reload.title_en).to eq("updated_title")
      expect(response).to redirect_to(user_with_product_tab_path(product))
    end

    it "re-renders the form with when invalid params are passed" do
      product = create :product, user: user

      expect {
        patch :update, params: { id: product.id, product: invalid_params }
      }.to_not change { product.reload.updated_at }

      expect(response).to render_template(:edit)
    end

    it "deletes images indicated by params" do
      product = create :product, user: user
      product.carousel_images.attach(io: File.open(carousel_image_files[0]), filename: "test.png")
      product.carousel_images.attach(io: File.open(carousel_image_files[1]), filename: "test.png")

      image_1, image_2 = product.carousel_images.to_a

      params = valid_params.merge("delete_carousel_image_ids" => [image_2.id.to_s])

      patch :update, params: { id: product.id, product: params }

      expect(product.reload.carousel_images.to_a).to eq([image_1])
      expect(response).to redirect_to(user_with_product_tab_path(product))
    end
  end

  describe "#publish" do
    it "publishes the product" do
      sign_in create(:admin)

      product = create :product, state: "for_review", user: user

      get :publish, params: { id: product.id }

      expect(product.reload.state).to eq("published")
      expect(response).to redirect_to(user_with_product_tab_path(product))
    end
  end

  describe "#archive" do
    it "archives the product" do
      product = create :product, state: "published", user: user

      get :archive, params: { id: product.id }

      expect(product.reload.state).to eq("archived")
      expect(response).to redirect_to(user_with_product_tab_path(product))
    end
  end

  describe "#reject" do
    it "rejects the product" do
      sign_in create(:admin)

      product = create :product, state: "for_review", user: user

      get :reject, params: { id: product.id }

      expect(product.reload.state).to eq("rejected")
      expect(response).to redirect_to(user_with_product_tab_path(product))
    end
  end

  describe "#embed_link" do
    it "shows a link to embed the product" do
      product = create :product, user: user

      get :embed_link, params: { id: product.id }

      expect(response).to render_template(:embed_link)
    end
  end

  describe "#embed" do
    it "shows an embedded product" do
      product = create :product

      get :embed, params: { id: product.id }

      expect(response).to render_template(:embed)
    end
  end

  describe "#embed_graphic" do
    it "shows an embedded product with a graphic when the product has a carousel image" do
      product = create :product
      product.carousel_images.attach(io: File.open(carousel_image_files[0]), filename: "test.png")

      get :embed_graphic, params: { id: product.id }

      expect(response).to render_template(:embed_graphic)
    end

    it "gracefully handles a product without a carousel image" do
      product = create :product

      get :embed_graphic, params: { id: product.id }

      expect(response).to render_template(:embed_graphic)
    end
  end
end
