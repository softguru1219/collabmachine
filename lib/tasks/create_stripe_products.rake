# use after resetting the stripe sandbox
# database must be reseeded after
require 'csv'

task create_stripe_products: :environment do
  seed_path = Rails.root.join("db", "seeds", "products.csv")
  seeds = CSV.open(seed_path, headers: :first_row).map(&:to_h)

  buyable_products = seeds.select do |s|
    s.fetch("subscription_access_level").present? && s.fetch("buyable") == "true"
  end

  buyable_products.each do |product|
    stripe_product = Stripe::Product.create(
      name: product.fetch("title"),
      active: true
    )

    Stripe::Price.create(
      product: stripe_product.id,
      active: true,
      unit_amount: (product.fetch("price").to_i * 100),
      currency: "cad",
      recurring: {
        interval: "month",
        interval_count: 1
      },
      tax_behavior: "exclusive",
      metadata: { subscription_access_level: product.fetch("subscription_access_level") }
    )
  end
end
