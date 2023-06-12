require 'rails_helper'

describe InsuranceQuotesController do
  render_views

  let!(:user) { create :user }

  describe "#new" do
    before { sign_in user }

    it "renders the form for a new insurance quote" do
      get :new

      expect(response).to render_template(:new)
    end
  end

  describe "#create" do
    before { sign_in user }

    it "creates the insurance quote from valid params" do
      params = {
        "insurance_quote" => {
          "name" => "Test User",
          "email" => "testuser@example.com",
          "phone" => "123-123-1234",
          "note" => "Some insurance quote details"
        }
      }

      expect(MessageMailer).to receive(:prepare_quick_insurance_quote).with(be_a(InsuranceQuote))

      expect {
        post :create, params: params
      }.to change(InsuranceQuote, :count).by(1)

      quote = InsuranceQuote.last

      expect(quote.name).to eq("Test User")
      expect(quote.email).to eq("testuser@example.com")
      expect(quote.phone).to eq("123-123-1234")
      expect(quote.note).to eq("Some insurance quote details")

      expect(response).to render_template(:create)
    end
  end
end
