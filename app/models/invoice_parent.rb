class InvoiceParent < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :invoiceable, polymorphic: true
end
