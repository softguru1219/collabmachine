class ProductCategory < ActiveRecord::Base
  extend Mobility

  translates :title

  validates :title, presence: true

  has_many :product_categorizations
  has_many :products, through: :product_categorizations
  has_many :serviceplace_products, -> { limit(15) }, through: :product_categorizations, source: :product

  MERCHANDISE_CATEGORY_ID = 5
  MEMBERSHIP_CATEGORY_ID = 6
end
