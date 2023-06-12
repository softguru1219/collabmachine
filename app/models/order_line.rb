class OrderLine < ApplicationRecord
  belongs_to :order, required: true
  belongs_to :product, required: true

  attribute :taxes, TaxLine.to_array_type
  validates :taxes, store_model: true

  # virtual attribute used when building order from order lines
  attr_accessor :vendor

  has_many :product_recommendations

  delegate :buyer, to: :order
end
