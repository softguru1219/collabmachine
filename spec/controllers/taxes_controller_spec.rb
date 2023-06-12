require "rails_helper"

describe TaxesController, type: :controller do
  let!(:user) { create :user }
  before { sign_in user }

  describe "#create" do
    let!(:valid_params) { { "tax" => { "name" => "QST", "rate" => "9.97", "number" => "" } } }
    it "creates the tax" do
      expect {
        post :create, params: valid_params
      }.to change(Tax, :count).by(1)

      tax = Tax.last

      expect(tax.name).to eq("QST")
      expect(tax.rate.to_s).to eq("9.97")
      expect(tax.user).to eq(user)

      expect(response).to redirect_to(user_path(user, anchor: "finances"))
    end
  end

  describe "#destroy" do
    let!(:tax) { create :tax, user: user }

    it "destroys the tax" do
      delete :destroy, params: { id: tax.id }

      expect(Tax.find_by(id: tax.id)).to eq(nil)
      expect(response).to redirect_to(user_path(user, anchor: "finances"))
    end
  end
end
