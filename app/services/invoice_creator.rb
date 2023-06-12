class InvoiceCreator
  attr_accessor :invoice

  def initialize(invoice:)
    @invoice = invoice
  end

  def call
    return false unless invoice.valid?

    create_on_stripe
    invoice.save
  end

  private

  def create_on_stripe
    ActiveRecord::Base.transaction do
      create_stripe_invoice_items
      stripe_invoice = create_stripe_invoice
      invoice.stripe_invoice_id = stripe_invoice.id
    end
  end

  def create_stripe_invoice_items
    invoice.invoice_lines.each do |line|
      Stripe::InvoiceItem.create({
        description: line.description,
        unit_amount: (line.rate * 100).to_i,
        quantity: line.quantity.to_i,
        customer: stripe_customer.id,
        currency: 'CAD'
      }, {
        stripe_account: user.stripe_profile.uid
      })
    end

    unique_taxes_with_sum.each do |tax|
      Stripe::InvoiceItem.create({
        description: tax[:name],
        unit_amount: (tax[:sum] * 100).to_i,
        quantity: 1,
        customer: stripe_customer.id,
        currency: 'CAD'
      }, {
        stripe_account: user.stripe_profile.uid
      })
    end
  end

  def create_stripe_invoice
    Stripe::Invoice.create({
      customer: stripe_customer.id,
      billing: 'send_invoice',
      due_date: 1.month.from_now.to_i
    }, {
      stripe_account: user.stripe_profile.uid
    })
  end

  def user
    @user ||= invoice.user
  end

  def stripe_customer
    @stripe_customer ||= StripeCustomerRetriever.new(target_account: user, user_to_create: invoice.customer).call
  end

  def unique_taxes_with_sum
    array = []
    invoice.invoice_lines.each do |line|
      line.taxes.each do |tax|
        if array.none? { |h| h[:name] == tax.description }
          array.push(
            name: tax.description,
            sum: line.amount_without_tax * tax.rate_as_decimal
          )
        else
          hash = array.find { |h| h[:name] == tax.description }
          hash[:sum] += line.amount_without_tax * tax.rate_as_decimal
        end
      end
    end
    array
  end
end
