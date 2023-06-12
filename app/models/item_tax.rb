class ItemTax < ActiveRecord::Base
  belongs_to :invoice_line
  belongs_to :tax, -> { with_deleted }

  def sum
    invoice_line.amount_without_tax * tax.rate_as_decimal
  end
end
