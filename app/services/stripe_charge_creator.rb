class StripeChargeCreator
  APPLICATION_FEE_PERCENT = 20.0
  REFERRAL_RATE = 0.05 # means 5% of total sale
  POINTER_RATE = 0.01

  attr_accessor :transaction, :customer

  def initialize(transaction:, customer:)
    @transaction = transaction
    @customer = customer
  end

  def call
    intent = Stripe::PaymentIntent.create(
      amount: amount + application_fee,
      currency: 'CAD',
      confirm: true,
      customer: customer.present? ? customer : transaction.sender.stripe_customer_id,
      description: transaction.description,
      metadata: { stripe_invoice_id: transaction.invoice.stripe_invoice_id }
    )

    charge = intent.charges.data[0]

    stripe_invoice = transaction.invoice.stripe_invoice
    stripe_invoice.metadata = { stripe_charge_id: charge.id }
    stripe_invoice.paid = true
    stripe_invoice.save

    transaction.update(paid: true, stripe_charge: intent.charges.data[0].id) if intent.status == "succeeded"

    if (transaction.sender.invited_by_id && transaction.sender.invited_by.stripe_profile && active_referral?)
      Stripe::Transfer.create({
        amount: referral_amount,
        currency: 'cad',
        destination: transaction.sender.invited_by.stripe_profile.uid,
        description: "Referall amount for #{transaction.sender.full_name}",
        source_transaction: charge.id
      })
    end

    parents = InvoiceParent.includes(:invoiceable).where(invoice_id: transaction.invoice, invoiceable_type: "Mission")

    parents.each do |parent|
      next unless parent.invoiceable.present? && parent.invoiceable.assignment.pointed_by.present?

      pointer = User.find(parent.invoiceable.assignment.pointed_by)
      Stripe::Transfer.create({
        amount: pointer_amount(parent.total),
        currency: 'cad',
        destination: pointer.stripe_profile.uid,
        description: "Pointer amount for suggesting #{transaction.sender.full_name}",
        source_transaction: charge.id
      })
    end

    Stripe::Transfer.create({
      amount: amount,
      currency: 'cad',
      destination: transaction.receiver.stripe_profile.uid,
      source_transaction: charge.id,
      metadata: { stripe_invoice_id: transaction.invoice.stripe_invoice_id }
    })
  end

  private

  def amount
    (transaction.invoice.amount * 100).to_i
  end

  def application_fee
    (transaction.invoice.application_fee * 100).to_i
  end

  def referral_amount
    (transaction.invoice.amount_without_tax * REFERRAL_RATE * 100).to_i
  end

  def pointer_amount(total)
    (total * POINTER_RATE * 100).to_i
  end

  def active_referral?
    transaction.sender.client_activation_date.blank? or
      transaction.sender.client_activation_date > 2.year.ago
  end
end
