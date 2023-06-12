class InvoiceLine < ActiveRecord::Base
  belongs_to :invoice
  has_many :item_taxes
  has_many :taxes, through: :item_taxes

  attribute :mission_id, :integer

  validates :rate, presence: true
  validates :quantity, presence: true
  validates :description, presence: true

  def amount
    amount_without_tax + taxes_sum
  end

  def amount_without_tax
    quantity * rate
  end

  def taxes_sum
    taxes.sum { |t| amount_without_tax * t.rate_as_decimal }
  end
end
