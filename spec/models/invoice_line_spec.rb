require 'rails_helper'

describe InvoiceLine do
  let(:user) { create(:user) }

  describe '#amount' do
    it 'multiply quantity by rate' do
      line = create(:invoice_line, quantity: 2, rate: 200)
      expect(line.amount).to eq 400
    end

    it 'multiply quantity by rate and taxes' do
      tax = create(:tax, rate: 10, user: user)
      line = create(:invoice_line, quantity: 2, rate: 200, taxes: [tax])
      expect(line.amount).to eq 440
    end
  end

  describe '#amount_without_tax' do
    it 'multiply quantity by rate' do
      line = create(:invoice_line, quantity: 2, rate: 200)
      expect(line.amount_without_tax).to eq 400
    end

    it 'multiply quantity by rate and no taxes' do
      tax = create(:tax, rate: 10, user: user)
      line = create(:invoice_line, quantity: 2, rate: 200, taxes: [tax])
      expect(line.amount_without_tax).to eq 400
    end
  end
end
