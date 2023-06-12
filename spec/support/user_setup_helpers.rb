module UserSetupHelpers
  def assign_customer_with_source(user)
    user.update!(stripe_customer_id: Rails.application.config.test_stripe_customer_id_with_source)
  end

  def assign_customer_without_source(user)
    user.update!(stripe_customer_id: Rails.application.config.test_stripe_customer_id_without_source)
  end

  def assign_customer_with_active_subscription(user)
    user.update!(stripe_customer_id: Rails.application.config.test_stripe_customer_id_with_active_subscription)
  end

  def assign_customer_without_active_subscription(user)
    user.update!(stripe_customer_id: Rails.application.config.test_stripe_customer_id_without_active_subscription)
  end
end

RSpec.configure do |config|
  config.include UserSetupHelpers
end
