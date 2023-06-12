class SubscriptionCheckoutsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new]
  after_action :verify_authorized

  def new
    authorize :subscription_checkout, :new?

    if !current_user.present?
      redirect_to new_user_registration_path, flash: { notice: t("subscription_checkouts.new.sign_up") }
    elsif current_user.gte_premium?
      redirect_to new_stripe_customer_portal_session_path
    else
      product = Product.find(params[:product_id])

      # see https://stripe.com/docs/payments/checkout/custom-success-page
      session = Stripe::Checkout::Session.create({
        success_url: with_session_id(success_subscription_checkouts_url),
        cancel_url: with_session_id(cancel_subscription_checkouts_url),
        customer: current_user.stripe_customer_id,
        payment_method_types: ['card'],
        customer_update: {
          address: "auto" # let Stripe use the customer address for taxes
        },
        subscription_data: {
          metadata: {
            type: SetUserAccessLevelFromSubscriptions::SUBSCRIPTION_TYPE,
            created_by_cm_user_id: current_user.id # currently for auditing only
          }
        },
        line_items: [
          { price: product.stripe_price_id, quantity: 1 },
        ],
        automatic_tax: {
          enabled: true
        },
        mode: 'subscription',
        locale: I18n.locale
      })

      redirect_to session.url
    end
  end

  def success
    authorize :subscription_checkout, :success?

    SetUserAccessLevelFromSubscriptions.call(current_user.stripe_customer_id)

    redirect_to dashboard_path, flash: { notice: t("subscription_checkouts.success.flash") }
  end

  def cancel
    authorize :subscription_checkout, :cancel?

    redirect_to dashboard_path, flash: { notice:  t("subscription_checkouts.cancel.flash") }
  end

  private

  def with_session_id(callback_url)
    "#{callback_url}?session_id={CHECKOUT_SESSION_ID}"
  end
end
