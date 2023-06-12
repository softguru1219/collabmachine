task reset_product_recommendation_counts: :environment do
  User.update_all(remaining_product_recommendations: ProductRecommendation::MONTHLY_ALLOWANCE)
end
