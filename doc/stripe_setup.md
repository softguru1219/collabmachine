# Subscriptions Setup

- create Stripe products with monthly recurring billing (tax exclusive of price)
- create CM products and set the stripe_price_id and subscription_access_level from the Stripe products above
- subscribe to stripe webhooks using the `/stripe_webhooks/:secret` endpoint
- in Stripe settings, set "If all retries for a payment fail -> cancel the subscription"
- in Stripe settings, enable Stripe Tax (automatic tax collection)

# Setup after clearing sandbox
- `rake setup_stripe`
- assign resulting billing portal config ID to `stripe_customer_portal_config_id`
