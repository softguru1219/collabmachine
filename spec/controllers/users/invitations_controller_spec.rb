require 'rails_helper'

describe Users::InvitationsController, type: :controller do
  render_views

  before { set_devise_mapping }

  before {
    @raw_invitation_token, @encrypted_invitation_token = Devise.token_generator.generate(User, :invitation_token)
  }

  let!(:admin) { create :admin }
  let!(:invited_user) {
    create(
      :user,
      first_name: "Invited",
      last_name: "User",
      email: "invited@user.com",
      invited_handle: "Invited",
      invited_by: admin
    ).tap(&:invite!).tap { |user| user.update!(invitation_token: @encrypted_invitation_token) }
  }

  describe "#new" do
    before { sign_in admin }

    it "renders the form to create new invitations" do
      get :new

      expect(response).to be_successful
    end
  end

  describe "#create" do
    before { sign_in admin }
    let!(:valid_params) {
      { "users" => { "0" => { "first_name" => "Test", "last_name" => "User", "email" => "test@example.com" } } }
    }

    it "creates an invitation" do
      expect {
        post :create, params: valid_params
      }.to change(User, :count).by(1)

      expect(response).to be_successful

      new_user = User.last

      expect(new_user.first_name).to eq("Test")
      expect(new_user.last_name).to eq("User")
      expect(new_user.email).to eq("test@example.com")
      expect(new_user.invitation_token).to_not be_nil
    end
  end

  describe "#edit" do
    it "renders a form for the user to enter their password" do
      get :edit, params: { invitation_token: @raw_invitation_token }

      expect(response).to be_successful
    end
  end

  describe "#update" do
    it "accepts the invitation" do
      put :update, params: {
        user: {
          invitation_token: @raw_invitation_token,
          password: "asdf1234",
          password_confirmation: "asdf1234",
          terms_accepted_at: false
        }
      }, xhr: true

      expect(response).to be_successful

      invited_user.reload

      expect(invited_user.invitation_accepted_at).to_not be_nil
      expect(invited_user.encrypted_password).to_not be_nil
    end
  end
end
