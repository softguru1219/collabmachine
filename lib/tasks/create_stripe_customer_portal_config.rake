task create_stripe_customer_portal_config: :environment do
  products = Product.subscription.published.buyable
  subscription_update_products_config = products.map do |product|
    price = Stripe::Price.retrieve(product.stripe_price_id)

    {
      product: price.product,
      prices: [price.id]
    }
  end

  config = Stripe::BillingPortal::Configuration.create(
    features: {
      customer_update: {
        enabled: true,
        allowed_updates: ["email"]
      },
      invoice_history: {
        enabled: false
      },
      payment_method_update: {
        enabled: true
      },
      subscription_cancel: {
        enabled: true,
        mode: "at_period_end",
        proration_behavior: "none"
      },
      subscription_pause: {
        enabled: false
      },
      subscription_update: {
        enabled: true,
        default_allowed_updates: ["price"],
        proration_behavior: "always_invoice",
        products: subscription_update_products_config
      }
    },
    business_profile: {
      privacy_policy_url: 'https://www.collabmachine.com',
      terms_of_service_url: 'https://www.collabmachine.com'
    }
  )

  puts "Config ID:"
  puts config.id
end
