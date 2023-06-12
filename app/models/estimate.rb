class Estimate < ApplicationRecord
  validates :title, :description, presence: true
  validates :email, presence: true, if: -> { phone&.empty? }
  validates :phone, presence: true, if: -> { email&.empty? }
end
