FactoryBot.define do
  factory :order_line do
    product_title { "Product 1" }
    product_quantity { 1 }
    product_price { 100 }
    product_amount { 100 }
    taxes { [TaxLine.new(name: "GST", rate_as_percent: BigDecimal(5), amount: BigDecimal(5))] }
    total_tax_amount { 5 }
    total_amount { 105 }
    product
  end
end
