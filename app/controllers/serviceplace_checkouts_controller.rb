class ServiceplaceCheckoutsController < ApplicationController
  before_action :set_body_classes
  skip_before_action :authenticate_user!, only: [:show]
  before_action :verify_full_name, except: [:show]
  after_action :verify_authorized, except: [:show]

  def show
    if current_user.present?
      redirect_to confirm_payment_information_serviceplace_checkout_path
    else
      redirect_to new_user_registration_path, flash: { notice: t("serviceplace_checkouts.show.sign_up") }
    end
  end

  def confirm_payment_information
    authorize :serviceplace_checkout

    @existing_card = current_user.default_card
    @out_of_canada = Geocoder.search(request.remote_ip).first.country != "CA"

    @vue_data = {
      stripePublishableKey: Figaro.env.stripe_publishable_key,
      existingCard: @existing_card
    }
  end

  def update_card
    authorize :serviceplace_checkout

    stripe_customer = current_user.stripe_customer

    if (stripe_customer.source = params[:stripe_card_token]) && stripe_customer.save
      head 200
    else
      head 500
    end
  end

  def confirm_purchase
    authorize :serviceplace_checkout

    redirect_to confirm_payment_information_serviceplace_checkout_path, flash: { alert: t("serviceplace_checkouts.show.province_non_existent") } unless Tax.provincial_taxes.key?(request.params["province"])

    cart = ShoppingCart.fetch_from_session(session)

    cart.provincial_taxes = Tax.provincial_taxes[request.params["province"]]["taxes"]

    @cart = cart.present
    @checksum = cart.checksum
    @province = request.params["province"]
  end

  def do_confirm_purchase
    authorize :serviceplace_checkout
    cart = ShoppingCart.fetch_from_session(session)
    cart.provincial_taxes = Tax.provincial_taxes[request.params["province"]]["taxes"]

    if cart.checksum == params[:checksum]
      purchase = PurchaseServiceplaceCart.call(cart, current_user)
      cart.clear
      cart.save_to_session(session)

      redirect_to view_invoice_serviceplace_checkout_path(purchase_id: purchase.id), flash: {
        notice: t("serviceplace_checkouts.shared.purchase_successful")
      }
    else
      redirect_to confirm_purchase_serviceplace_checkout_path, flash: {
        notice: t("serviceplace_checkouts.shared.cart_changed")
      }
    end
  end

  def view_invoice
    @purchase = Purchase.find(params[:purchase_id])

    authorize @purchase, :show?
  end

  private

  def set_body_classes
    @body_classes = "bg-light"
  end
end
