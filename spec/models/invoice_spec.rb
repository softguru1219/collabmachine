require 'rails_helper'

describe Invoice do
  let(:user) { create(:user) }

  describe '#amount' do
    it 'gives the sum of lines amounts' do
      line1 = build(:invoice_line, quantity: 2, rate: 200)
      line2 = build(:invoice_line, quantity: 1, rate: 150)
      invoice = build_invoice(invoice_lines: [line1, line2])

      expect(invoice.amount).to eq(550)
    end

    it 'gives the sum of lines amounts with taxes' do
      tax = create(:tax, rate: 10, user: user)
      line1 = build(:invoice_line, quantity: 2, rate: 200, taxes: [tax])
      line2 = build(:invoice_line, quantity: 1, rate: 150)
      invoice = build_invoice(invoice_lines: [line1, line2])

      expect(invoice.amount).to eq(590)
    end
  end

  describe '#amount_without_tax' do
    it 'gives the sum of lines amounts' do
      line1 = build(:invoice_line, quantity: 2, rate: 200)
      line2 = build(:invoice_line, quantity: 1, rate: 150)
      invoice = build_invoice(invoice_lines: [line1, line2])

      expect(invoice.amount_without_tax).to eq(550)
    end

    it 'gives the sum of lines amounts with no taxes' do
      tax = create(:tax, rate: 10, user: user)
      line1 = build(:invoice_line, quantity: 2, rate: 200, taxes: [tax])
      line2 = build(:invoice_line, quantity: 1, rate: 150)
      invoice = build_invoice(invoice_lines: [line1, line2])

      expect(invoice.amount_without_tax).to eq(550)
    end
  end

  describe '#taxes_with_total' do
    it 'gives an array with taxes name and sum' do
      tax1 = create(:tax, name: 'tax1', rate: 10, user: user)
      tax2 = create(:tax, name: 'tax2', rate: 20, user: user)
      line1 = build(:invoice_line, quantity: 2, rate: 200, taxes: [tax1, tax2])
      line2 = build(:invoice_line, quantity: 1, rate: 150, taxes: [tax1])
      invoice = build_invoice(invoice_lines: [line1, line2])
      invoice.save

      taxes_array = invoice.taxes_with_total

      expect(taxes_array.length).to eq(2)
      expect(taxes_array[0][:name].include?('tax1'))
      expect(taxes_array[0][:sum]).to eq(55)

      expect(taxes_array[1][:name].include?('tax2'))
      expect(taxes_array[1][:sum]).to eq(80)
    end

    it 'gives the sum of lines amounts with no taxes' do
      tax = create(:tax, rate: 10, user: user)
      line1 = build(:invoice_line, quantity: 2, rate: 200, taxes: [tax])
      line2 = build(:invoice_line, quantity: 1, rate: 150)
      invoice = build_invoice(invoice_lines: [line1, line2])

      expect(invoice.amount_without_tax).to eq(550)
    end
  end

  describe '#application_fee' do
    it 'compute the fee took by collab' do
      line = build(:invoice_line, quantity: 1, rate: 100)
      invoice = build_invoice(invoice_lines: [line])
      expect(invoice.application_fee).to eq(20)
    end
  end

  describe '#stripe_fee' do
    it 'compute the fee took by collab' do
      line = build(:invoice_line, quantity: 1, rate: 100)
      invoice = build_invoice(invoice_lines: [line])
      expect(invoice.stripe_fee).to eq(3.2)
    end
  end

  describe '#overall_amount' do
    it 'gives amount with all fees included' do
      tax = create(:tax, rate: 50, user: user)
      line1 = build(:invoice_line, quantity: 2, rate: 200, taxes: [tax])
      line2 = build(:invoice_line, quantity: 1, rate: 400)
      invoice = build_invoice(invoice_lines: [line1, line2])

      expect(invoice.overall_amount.to_f).to eq 1200
    end
  end

  describe '#stripe_invoice' do
    it 'gives the stripe invoice corresponding to the ID' do
      invoice = build_invoice(stripe_invoice_id: 1)
      stripe_invoice = double

      allow(Stripe::Invoice).to receive(:retrieve)
        .and_return(stripe_invoice)
        .with('1', stripe_account: invoice.user.stripe_profile.uid)

      expect(invoice.stripe_invoice).to eq(stripe_invoice)
    end
  end

  describe ".by_description" do
    it "returns invoices whose description match the query" do
      matching = create :invoice, description: "Matching", invoice_lines: [build(:invoice_line)]
      _other = create :invoice, description: "Other", invoice_lines: [build(:invoice_line)]

      expect(Invoice.by_description("match")).to eq([matching])
    end

    it "returns invoices whose items' descriptions match the query" do
      matching = create :invoice, invoice_lines: [build(:invoice_line, description: "Matching")]
      _other = create :invoice, invoice_lines: [build(:invoice_line, description: "Other")]

      expect(Invoice.by_description("match")).to eq([matching])
    end
  end

  def build_invoice(attributes = {})
    user = create(:user)
    create(:profile, user: user, provider: 'stripe_connect')
    customer = build(:user)
    attributes.reverse_merge!(
      user: user,
      customer: customer,
      invoice_lines: [build(:invoice_line)]
    )
    build(:invoice, attributes)
  end
end
