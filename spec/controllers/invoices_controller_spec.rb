require 'rails_helper'

describe InvoicesController do
  render_views

  let!(:user) { create :user }
  let!(:profile) { create :profile, user: user, provider: "stripe_connect", uid: "acct_1J2zDlImLCgNPewX" }
  let!(:customer) { create :user, first_name: "Customer", last_name: "ForTheInvoice" }
  let!(:project) { create :project, user: customer }
  let!(:mission) { create :mission, project: project }
  let!(:tax) { create :tax, user: user }

  describe "#index" do
    before { sign_in user }
    let!(:invoice) { create :invoice, customer: customer, user: user, invoice_lines: [build(:invoice_line)] }

    it "shows users their invoices" do
      get :index

      expect(response).to render_template(:index)
      expect(response.body).to include("Customer ForTheInvoice")
    end
  end

  describe "#new" do
    before { sign_in user }

    it "renders the form" do
      get :new

      expect(response).to render_template(:new)
    end
  end

  describe "#create" do
    before { sign_in user }

    let!(:valid_params) {
      {
        "invoice" => {
          "mission" => "",
          "customer_id" => customer.id.to_s,
          "external_name" => "",
          "external_email" => "",
          "mission_ids" => ["", mission.id.to_s],
          "project_ids" => ["", project.id.to_s],
          "description" => "some description for the invoice",
          "invoice_lines_attributes" => {
            "0" => {
              "description" => "line item 1",
              "quantity" => "1",
              "rate" => "20",
              "mission_id" => mission.id.to_s,
              "tax_ids" => ["", tax.id.to_s],
              "_destroy" => "false"
            },
            "1" => {
              "description" => "line item 2",
              "quantity" => "2",
              "rate" => "40",
              "mission_id" => mission.id.to_s,
              "tax_ids" => [""],
              "_destroy" => "false"
            },
            "2" => {
              "description" => "",
              "quantity" => "",
              "rate" => "",
              "mission_id" => mission.id.to_s,
              "tax_ids" => [""],
              "_destroy" => "1"
            }
          }
        }
      }
    }

    # TODO: refactor controller action and service to make this more testable
    it "creates an invoice from valid params" do
      expect_any_instance_of(InvoiceCreator).to receive(:call).and_return(true)

      post :create, params: valid_params

      expect(response).to redirect_to(invoices_path)
    end
  end

  describe "#show" do
    it "shows the invoice to a logged in user" do
      invoice = create :invoice, customer: customer, user: user, invoice_lines: [build(:invoice_line)]

      sign_in user

      get :show, params: { id: invoice.id }

      expect(response).to render_template(:show)
    end

    it "shows the invoice to an unauthenticated user, if they have the correct public token" do
      invoice = create :invoice_without_customer, user: user, invoice_lines: [build(:invoice_line)]

      get :show, params: { id: invoice.id, token: invoice.public_token }

      expect(response).to render_template(:show)
    end

    it "forbids showing the invoice if an incorrect token is given" do
      invoice = create :invoice_without_customer, user: user, invoice_lines: [build(:invoice_line)]

      get :show, params: { id: invoice.id, token: "fake" }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "#update_payment_information" do
    let!(:invoice) {
      create(
        :invoice_without_customer,
        user: user,
        invoice_lines: [build(:invoice_line)],
        external_name: "some_unauthenticated_user",
        external_email: "external@example.com"
      )
    }

    let!(:valid_params) {
      {
        "stripe_temporary_token" => "tok_1JGR4EFiUwJySKD8WwzvqzZL",
        "id" => invoice.id.to_s
      }
    }

    it "allows an unauthenticated user to update their payment information with a stripe elements token and pay the invoice" do
      customer = double("customer")

      expect(Stripe::Customer).to receive(:new).with(
        description: "some_unauthenticated_user",
        email: "external@example.com"
      ).and_return(customer)

      expect(customer).to receive(:source=).with("tok_1JGR4EFiUwJySKD8WwzvqzZL")
      expect(customer).to receive(:save).and_return(true)

      expect_any_instance_of(StripeChargeCreator).to receive(:call)

      patch :update_payment_information, params: valid_params

      expect(response).to redirect_to(invoice_path(invoice, token: invoice.public_token))
    end
  end

  describe "#edit" do
    before { sign_in user }
    let!(:invoice) { create :invoice, customer: customer, user: user, invoice_lines: [build(:invoice_line)] }
    it "renders a form to edit the invoice" do
      get :edit, params: { id: invoice.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "#update" do
    let!(:invoice) { create :invoice, description: "original_description", customer: customer, user: user, invoice_lines: [build(:invoice_line)] }
    let!(:updated_params) {
      {
        "invoice" => {
          "mission" => "",
          "customer_id" => customer.id.to_s,
          "external_name" => "",
          "external_email" => "",
          "mission_ids" => ["", mission.id.to_s],
          "project_ids" => ["", project.id.to_s],
          "description" => "updated_description",
          "invoice_lines_attributes" => {
            "0" => {
              "description" => "line item 1",
              "quantity" => "1.0",
              "rate" => "20.0",
              "mission_id" => mission.id.to_s,
              "tax_ids" => [""],
              "_destroy" => "false",
              "id" => invoice.invoice_lines.first.id.to_s
            }
          }
        },
        "id" => invoice.id
      }
    }
    before { sign_in user }

    it "updates the invoice" do
      patch :update, params: updated_params

      invoice.reload

      expect(invoice.description).to eq("updated_description")
      expect(response).to redirect_to(invoices_path)
    end
  end

  describe "#destroy" do
    before { sign_in user }
    let!(:invoice) { create :invoice, customer: customer, user: user, invoice_lines: [build(:invoice_line)] }

    it "destroys the invoice" do
      expect {
        delete :destroy, params: { id: invoice.id }
      }.to change(Invoice, :count).by(-1)

      expect(Invoice.find_by(id: invoice.id)).to eq(nil)
    end
  end
end
