class CheckoutController < ApplicationController
  def create
    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        name: 'RANDOMLY',
        description: "Faites connaissance. Installez l'effervescence",
        amount: 1000,
        currency: 'cad',
        quantity: 1
      }],
      success_url: checkout_success_url,
      cancel_url: checkout_cancel_url
    )

    respond_to do |format|
      format.js
    end
  end

  def cancel
    redirect_to randomly_path
  end

  def success; end
end
