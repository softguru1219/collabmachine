class SubscriptionPlansController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :send_message_to_admin_partner]
  after_action :verify_authorized

  def index
    authorize :subscription_plan, :index?

    @body_classes = "bg-light"

    @freemium_plan = Product.published.where("title->>'fr' = ?", "Freemium").first
    @premium_plan = Product.published.find_by!(subscription_access_level: Product.subscription_access_levels.premium)
    @platinum_plan = Product.published.find_by!(subscription_access_level: Product.subscription_access_levels.platinum)
    @partner_plan = Product.published.find_by!(subscription_access_level: Product.subscription_access_levels.partner)

    layout = current_user.present? ? "application" : "front"
    @wrapper = true

    render :index, layout: layout
  end

  def send_message_to_admin_partner
    if user_signed_in?
      params[:sender] = current_user.email
      MessageMailer.send_message_to_admin_partner(params).deliver_now
    else
      params[:sender] = ""
      MessageMailer.send_message_to_admin_partner_bigblue(params).deliver_now
    end

    # TODO: should catch if it worked or not.
    render json: { status: 'OK' }
  end
end
