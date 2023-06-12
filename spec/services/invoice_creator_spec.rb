require 'rails_helper'

describe InvoiceCreator do
  describe '#call' do
    before do
      stripe_invoice = double(Stripe::Invoice, id: 1)
      stripe_customer = double(Stripe::Customer, id: 2)
      stripe_customer_retriver = double(call: stripe_customer)
      allow(Stripe::Invoice).to receive(:create).and_return(stripe_invoice)
      allow(Stripe::InvoiceItem).to receive(:create)
      allow(StripeCustomerRetriever).to receive(:new).and_return(stripe_customer_retriver)
    end

    context 'when the invoice is valid' do
      it 'creates an invoice' do
        invoice = build_invoice
        expect(invoice).to receive(:save)
        InvoiceCreator.new(invoice: invoice).call
      end

      it 'returns true' do
        invoice = build_invoice
        allow(invoice).to receive(:valid?).and_return(true)
        actual = InvoiceCreator.new(invoice: invoice).call
        expect(actual).to be_truthy
      end

      it 'creates an invoice on stripe' do
        line = build(:invoice_line)
        invoice = build_invoice(invoice_lines: [line])

        expect(Stripe::Invoice).to receive(:create)

        InvoiceCreator.new(invoice: invoice).call
      end

      it 'creates a line on stripe for each line of the invoice' do
        line1 = build(:invoice_line)
        line2 = build(:invoice_line)
        invoice = build_invoice(invoice_lines: [line1, line2])

        expect(Stripe::InvoiceItem).to receive(:create).twice

        InvoiceCreator.new(invoice: invoice).call
      end

      it 'saves the id of the invoice in stripe' do
        line = build(:invoice_line)
        invoice = build_invoice(invoice_lines: [line])

        InvoiceCreator.new(invoice: invoice).call

        expect(invoice.stripe_invoice_id).to eq '1'
      end
    end

    describe 'when the invoice is not valid' do
      it 'returns false when the invoice is not valid' do
        invoice = build_invoice
        allow(invoice).to receive(:valid?).and_return(false)
        actual = InvoiceCreator.new(invoice: invoice).call
        expect(actual).to be_falsy
      end
    end
  end

  def build_invoice(attributes = {})
    user = create(:user)
    create(:profile, user: user, provider: 'stripe_connect')
    customer = build(:user)
    line = build(:invoice_line)
    attributes.reverse_merge!(
      user: user, customer: customer, invoice_lines: [line]
    )
    build(:invoice, attributes)
  end
end
