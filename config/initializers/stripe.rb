Rails.configuration.stripe = {
  publishable_key: Figaro.env.stripe_publishable_key,
  secret_key: Figaro.env.stripe_secret_key
  # publishable_key: ENV['PUBLISHABLE_KEY'],
  # secret_key: ENV['SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
