require "rails_helper"

describe TransactionsController, type: :controller do
  let!(:invoicer) { create :user }
  let!(:invoicee) { create :user }
  let!(:project) { create :project, user: invoicee }
  let!(:mission) { create :mission, project: project }
  let!(:applicant) { create :applicant, user: invoicer, mission: mission, state: "assigned" }
  let!(:invoice) { create :invoice, user: invoicer, customer: invoicee, invoice_lines: [build(:invoice_line)] }

  before { sign_in invoicee }

  describe "#create" do
    it "charges the invoicee if the invoice is not paid yet" do
      expect_any_instance_of(StripeChargeCreator).to receive(:call)

      expect {
        post :create, params: { invoice_id: invoice.id }
      }.to change(Transaction, :count).by(1)

      transaction = Transaction.last

      expect(transaction.invoice).to eq(invoice)

      expect(response).to redirect_to(invoice_path(invoice))
    end

    it "redirects to the invoices index if the invoice is already paid" do
      create :transaction, invoice: invoice, paid: true

      expect {
        post :create, params: { invoice_id: invoice.id }
      }.to_not change(Transaction, :count)

      expect(response).to redirect_to(invoices_path)
    end
  end
end
