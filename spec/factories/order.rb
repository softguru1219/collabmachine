FactoryBot.define do
  factory :order do
    total_product_amount { 100 }
    vendor_name { "Vendor McVendorson" }
    vendor_email { "vendor@example.com" }
    buyer_name { "Buyer McBuyerson" }
    buyer_email { "buyer@example.com" }
    buyer { association :user }
    vendor { association :user }
    taxes { [TaxLine.new(name: "GST", rate_as_percent: BigDecimal(5), amount: BigDecimal(5))] }
    total_tax_amount { 5 }
    total_amount { 105 }
    state { "paid_out_to_vendor" }
    vendor_payout_amount { BigDecimal("94.5") }
    stripe_fee_amount { BigDecimal(5) }
    total_app_fee_amount { BigDecimal(5) }
    buyer_stripe_charge_id { ":buyer_stripe_charge_id:" }
    vendor_payout_stripe_transfer_id { ":vendor_payout_stripe_transfer_id:" }
    purchase
  end
end
