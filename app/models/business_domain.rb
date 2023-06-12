class BusinessDomain < ApplicationRecord
  extend Mobility
  has_many :business_sub_domains, dependent: :destroy
  translates :name
end
