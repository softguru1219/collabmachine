class ProductTax < ApplicationRecord
  belongs_to :product
  belongs_to :tax
end
