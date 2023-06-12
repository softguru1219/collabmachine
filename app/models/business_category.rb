class BusinessCategory < ApplicationRecord
  extend Mobility
  belongs_to :business_sub_domain
  has_many :specialties, dependent: :destroy
  translates :abr
  translates :name
  translates :display
end
