class InsuranceQuote < ActiveRecord::Base
  validates :name, :email, :phone, presence: true
end
