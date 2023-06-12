class StripeCustomerRetriever
  attr_accessor :target_account, :user_to_create

  def initialize(target_account:, user_to_create:)
    @target_account = target_account
    @user_to_create = user_to_create
  end

  def call
    customer = Stripe::Customer.list({
      email: user_to_create.email
    }, {
      stripe_account: target_account.stripe_profile.uid
    }).first

    return customer if customer

    Stripe::Customer.create({
      description: user_to_create.username,
      email: user_to_create.email
    }, {
      stripe_account: target_account.stripe_profile.uid
    })
  end
end
