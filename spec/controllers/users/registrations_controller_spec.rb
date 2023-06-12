require 'rails_helper'

describe Users::RegistrationController do
  render_views

  before { set_devise_mapping }

  describe "#create" do
    let!(:valid_params) {
      {
        "user" => {
          "first_name" => "Test",
          "last_name" => "User",
          "company" => "Company",
          "email" => "test@user.com",
          "password" => "asdfasdf123",
          "password_confirmation" => "asdfasdf123"
        }
      }
    }
    let!(:invalid_params) {
      {
        "user" => {
          "first_name" => "Test",
          "last_name" => "User",
          "company" => "Company",
          "email" => "test@user.com",
          "password" => "asdfasdf123",
          "password_confirmation" => "not_matching"
        }
      }
    }
    it "creates the user when valid params are given" do
      expect {
        post :create, params: valid_params
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.first_name).to eq("Test")
      expect(user.last_name).to eq("User")
      expect(user.company).to eq("Company")
      expect(user.encrypted_password).to_not be_nil

      expect(response).to redirect_to(user_steps_path)
    end

    it "doesn't create the user when invalid params are given" do
      expect {
        post :create, params: invalid_params
      }.to_not change(User, :count)

      expect(response).to render_template(:new)
    end
  end
end
