FactoryBot.define do
  factory :product_recommendation do
    product
    association :recommended_by_user, factory: :user
    association :recommended_to_user, factory: :user
  end
end
