require 'rails_helper'

describe StripeChargeCreator, vcr: true do
  before do
    stripe_invoice = spy(Stripe::Invoice, amount: 100)
    allow(Stripe::Invoice).to receive(:new).and_return(stripe_invoice)
  end

  describe '#call' do
    it 'Create a charge on stripe' do
      transaction = build_transaction

      StripeChargeCreator.new(transaction: transaction, customer: "cus_Jg51gxAIfpx22a").call
    end

    it 'Sets the transaction as paid if it is' do
      transaction = build_transaction
      charge = double(paid?: true, id: '123')

      allow(Stripe::Charge).to receive(:create).and_return(charge)

      StripeChargeCreator.new(transaction: transaction, customer: "cus_Jg51gxAIfpx22a").call

      expect(transaction).to be_paid
      expect(transaction.stripe_charge).to eq 'ch_1JDua7FiUwJySKD8jh3bLrBA'
    end
  end

  describe '#amount' do
    it 'is invoice amount' do
      transaction = build_transaction(invoice_line: { quantity: 1, rate: 100 })
      actual = StripeChargeCreator.new(transaction: transaction, customer: "cus_Jg51gxAIfpx22a").send(:amount)
      expect(actual).to eq 10000
    end
  end

  def build_transaction(options = {})
    options[:invoice_line] ||= { quantity: 2, rate: 1000 }
    sender = create(:user, stripe_customer_id: 'stripe_customer_id')
    receiver = create(:user)
    create(:profile, provider: 'stripe_connect', uid: 'acct_1J2zDlImLCgNPewX', user: receiver)
    invoice_line = create(:invoice_line, options[:invoice_line])
    invoice = create(
      :invoice, user: receiver, customer: sender, invoice_lines: [invoice_line]
    )
    create(:transaction, invoice: invoice)
  end
end
