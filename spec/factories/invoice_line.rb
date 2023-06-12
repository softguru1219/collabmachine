FactoryBot.define do
  factory :invoice_line do
    description { 'Invoice Line' }
    rate { 100 }
    quantity { 1 }
  end
end
