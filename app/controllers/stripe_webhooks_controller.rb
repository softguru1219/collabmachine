class StripeWebhooksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]
  protect_from_forgery except: :create

  def create
    # Validate webhook source using best-effort method of a secret url param.
    # Stripe's validation (which uses the entire webhook string body) is not used because it makes the endpoint difficult to test.
    #
    # This is *only* to prevent this endpoint being abused to make us exceed our Stripe rate limit.
    #
    # Since `SetUserAccessLevelFromSubscriptions` fetches data directly from stripe, unauthorized access
    # to this endpoint cannot maliciously modify data.
    if params[:secret] == Rails.application.config.stripe_webhook_secret
      event_type = params.fetch("stripe_webhook").fetch("type")
      case event_type
      when "customer.subscription.created", "customer.subscription.updated", "customer.subscription.deleted"
        stripe_customer_id = params.fetch("data").fetch("object").fetch("customer")
        SetUserAccessLevelFromSubscriptions.call(stripe_customer_id)
      else
        raise "Unhandled event: #{event_type}"
      end

      head :ok
    else
      head :forbidden
    end
  end
end
