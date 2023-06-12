require 'rails_helper'

describe Invoice, vcr: true do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:company) { create(:company) }

  let(:invoice_line) { create(:invoice_line) }
  let!(:first_invoice) { create(:invoice, user: user, customer: admin, invoice_lines: [invoice_line], description: "Bonjour toto") }

  before do
    create(:invoice, user: user, customer: company, invoice_lines: [invoice_line], description: "Bonjour tata")
    create(:invoice, user: admin, customer: company, invoice_lines: [invoice_line])
  end

  context 'by state' do
    it 'can find all invoice paid and not paid' do
      create(:transaction, invoice: first_invoice, paid: true)
      expect(Invoice.count).to eq 3
      expect(Invoice.by_state('paid').count).to eq 1
      expect(Invoice.by_state('not paid').count).to eq 2
    end

    it 'can return all if unknown state' do
      expect(Invoice.count).to eq 3
      expect(Invoice.by_state('asdad').count).to eq 3
    end
  end

  context 'by customer' do
    it 'can find all invoice with customer' do
      first_invoice.update(customer: user)

      expect(Invoice.count).to eq 3
      expect(Invoice.by_customer(user.id).count).to eq 1
    end

    it 'can return all if no invoice match' do
      expect(Invoice.count).to eq 3
      expect(Invoice.by_customer(nil).count).to eq 0
    end
  end

  context 'by user (invoice creator)' do
    let(:other_user) { create(:user) }

    it 'can find all invoice with user' do
      first_invoice.update(user: other_user)

      expect(Invoice.count).to eq 3
      expect(Invoice.by_user(other_user.id).count).to eq 1
    end

    it 'can return all if no invoice match' do
      expect(Invoice.count).to eq 3
      expect(Invoice.by_user(nil).count).to eq 0
    end
  end
end
