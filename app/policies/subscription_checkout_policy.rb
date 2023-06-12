class SubscriptionCheckoutPolicy < UnauthenticatedPolicy
  def new?
    true
  end

  def success?
    user.present?
  end

  def cancel?
    user.present?
  end
end
