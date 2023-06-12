class ProductCategorization < ActiveRecord::Base
  belongs_to :product
  belongs_to :product_category
end
