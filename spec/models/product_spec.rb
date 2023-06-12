require 'rails_helper'

describe Product do
  describe ".by_title" do
    it "searches for the product by title" do
      product = create :product, title: "Some very long title"
      _other_product = create :product

      expect(Product.by_title("very long")).to eq([product])
    end
  end

  describe ".create" do
    it "creates a product and sends a notification" do
      user = create :user, first_name: ":first:", last_name: ":last:"
      product = Product.create!(title: "some title", price: 200, user: user)

      expect(product.state).to eq("for_review")
      expect(Message.last.subject).to eq("Product 'some title' created by :first: :last:")
    end
  end

  describe "#publish" do
    it "publishes the product and sends a notification to the user" do
      user = create :user
      product = create :product, title: "some title",  user: user, state: "for_review"

      product.publish

      expect(product.state).to eq("published")
      expect(Message.order(created_at: :desc).first.subject).to eq("Product 'some title' was published")
    end
  end

  describe "validates_subscription_price_id" do
    it "raises an error if the product is buyable subscription and it doesn't have a price ID" do
      product = build(:product, stripe_price_id: nil, subscription_access_level: "premium", buyable: true)

      expect(product).to_not be_valid
      expect(product.errors[:stripe_price_id]).to_not be_empty
    end
  end

  describe "nilifying stripe_price_id" do
    it "it nilifies `stripe_price_id` if it's blank" do
      product = build(:product, stripe_price_id: "")
      expect(product).to be_valid
      expect(product.stripe_price_id).to eq(nil)
    end
  end
end
