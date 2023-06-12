class TransactionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]

  def create
    invoice = Invoice.find(params[:invoice_id])
    if invoice.paid?
      redirect_to invoices_path, alert: 'The invoice is already paid'
    else
      transaction = Transaction.create(invoice: invoice)
      StripeChargeCreator.new(transaction: transaction, customer: nil).call if transaction.persisted?
      activate_client
      respond_with transaction, location: invoice_path(invoice, token: invoice.public_token)
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:invoice_id, :stripe_customer)
  end

  def activate_client
    if current_user.present? and current_user.client_activation_date.blank?
      current_user.client_activation_date = Time.now
      current_user.save
    end
  end
end
