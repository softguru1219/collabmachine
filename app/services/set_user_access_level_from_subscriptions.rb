module SetUserAccessLevelFromSubscriptions
  # indepotent module that sets the user's access level based on their stripe customer's current subscriptions

  SUBSCRIPTION_TYPE = "cm_access_level_subscription".freeze
  VALID_STATUSES = [
    "active",
    "past_due", # still retrying payments
    "trialing"
  ].freeze

  extend self

  def call(stripe_customer_id)
    user = User.find_by(stripe_customer_id: stripe_customer_id)

    # 'admin' and 'partner' access levels are manually managed
    # that means that if a former or admin or partner wants to subscribe, they must be set to "freemium" first
    return if !user.present? || user.admin? || user.partner?

    customer = Stripe::Customer.retrieve(stripe_customer_id, expand: "subscriptions")

    set_user_access_level(user, customer.subscriptions)
  end

  def set_user_access_level(user, subscriptions)
    valid_subscriptions = subscriptions.select do |subscription|
      access_level_subscription?(subscription) && valid_subscription?(subscription)
    end
    latest_valid_subscription = valid_subscriptions.max_by(&:current_period_end)

    if latest_valid_subscription.present?
      product = Product.find_by(stripe_price_id: subscription_price_id(latest_valid_subscription))
      access_level = product.subscription_access_level
      user.update!(access_level: access_level)
    else
      user.update!(access_level: User.access_levels.freemium)
    end
  end

  def valid_subscription?(subscription)
    VALID_STATUSES.include?(subscription.status)
  end

  # only handle subscriptions that follow this module's logic
  def access_level_subscription?(subscription)
    subscription.metadata[:type] == SUBSCRIPTION_TYPE
  end

  def subscription_price_id(subscription)
    raise "Should only be one item" unless subscription.items.count == 1

    item = subscription.items.first

    item.price.id
  end
end
