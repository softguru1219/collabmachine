class BusinessSubDomain < ApplicationRecord
  extend Mobility
  belongs_to :business_domain
  has_many :business_categories, dependent: :destroy
  translates :name
  translates :display

  def delete
  	self.business_categories.destroy_all
  	self.destroy
  end
end
