class ProductRecommendation < ApplicationRecord
  PAYOUT_RATE = BigDecimal("0.01")
  MONTHLY_ALLOWANCE = 10

  validate :cannot_recommend_to_self

  belongs_to :recommended_by_user, class_name: "User", required: true
  belongs_to :recommended_to_user, class_name: "User", required: true
  belongs_to :product, required: true
  belongs_to :order_line, required: false

  def cannot_recommend_to_self
    errors.add(:recommended_to_user_id, "Can't recommend to self") if recommended_by_user_id == recommended_to_user_id
  end

  def cannot_recommend_to_vendor
    errors.add(:recommended_to_user_id, "Can't recommend to product vendor") if recommended_to_user == product.vendor.user
  end

  def paid_out?
    payout_stripe_transfer_id.present?
  end
end
