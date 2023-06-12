FactoryBot.define do
  factory :product do
    title { 'Software Development Services (10 hours)' }
    price { 600 }
    description { "Build or enhance your business's website" }
    intended_audience { "People who want a user-friendly and cost-effective website" }
    value_proposition { "I will make you an amazing website" }
    state { Product.states.published }
    stripe_price_id { nil }
    subscription_access_level { nil }
    user
  end

  factory :subscription_product, parent: :product do
    stripe_price_id { ":stripe-price-id:" }
    subscription_access_level { "premium" }
  end
end
