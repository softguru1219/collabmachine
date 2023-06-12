require 'rails_helper'

describe FinancialInfosController do
  render_views

  let!(:user) { create :user }

  # template not implemented/action used
  # describe "#new" do
  #   before{ sign_in user }

  #   it "foo" do
  #     get :new

  #     expect(response).to render_template(:new)
  #   end
  # end

  describe "#create" do
    it "creates the financial info" do
      sign_in user

      valid_params = { "financial_info" => { "institution" => "123", "transit" => "456", "account" => "789" } }

      expect {
        post :create, params: valid_params
      }.to change(FinancialInfo, :count).by(1)

      info = FinancialInfo.last

      expect(info.user).to eq(user)
      expect(info.institution).to eq("123")
      expect(info.transit).to eq("456")
      expect(info.account).to eq("789")

      expect(response).to redirect_to(user_path(user, anchor: "finances"))
    end
  end

  describe "#destroy" do
    it "destroys the financial info" do
      sign_in user

      info = create :financial_info, user: user

      delete :destroy, params: { id: info.id }

      expect(FinancialInfo.find_by(id: info.id)).to eq(nil)

      expect(response).to redirect_to(user_path(user, anchor: "finances"))
    end
  end
end
