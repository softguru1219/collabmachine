class StripeCustomerPortalSessionsController < ApplicationController
  def new
    session = Stripe::BillingPortal::Session.create({
      customer: current_user.stripe_customer_id,
      configuration: Rails.application.config.stripe_customer_portal_id,
      return_url: dashboard_url,
      locale: I18n.locale
    })

    redirect_to session.url
  end
end
