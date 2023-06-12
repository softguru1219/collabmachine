task setup_stripe: [:create_stripe_products, "db:reset", :create_stripe_customer_portal_config] do
  puts "Stripe setup completed"
end
