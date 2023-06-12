require "rails_helper"

describe UsersController, type: :controller do
  render_views

  shared_context "existing_user" do
    let!(:user) { create :user, first_name: "Test", last_name: "User" }
    let!(:admin) { create :admin }
    let!(:message) { create :message, recipient: user.id, subject: "User's Message" }
    let!(:project_created_by_user) { create :project, user: user, title: "User's Project" }
    let!(:tax) { create :tax, user: user }
    let!(:financial_info) { create :financial_info, user: user }
    let!(:client) { create :user }
    let!(:client_project) { create :project, user: user, title: "Client's Project" }
    let!(:client_project_mission) { create :mission, project: client_project }
    let!(:applicant) { create :applicant, user: user, mission: client_project_mission, state: "assigned" }
  end

  describe "#index" do
    include_context "existing_user"

    it "displays the index page" do
      sign_in user

      get :index

      expect(response).to render_template(:index)

      expect(response.body).to include("Test User")
    end
  end

  describe "#admin_index" do
    include_context "existing_user"

    it "displays the index page" do
      sign_in admin

      get :index

      expect(response).to render_template(:index)

      expect(response.body).to include("Test User")
    end
  end

  describe "#show" do
    include_context "existing_user"

    it "displays the show page" do
      sign_in user

      category = create :product_category, title: "Some category"
      create :product, title: "Some product", categories: [category], user: user

      get :show, params: { id: user.id }

      expect(response).to render_template(:show)

      expect(response.body).to include("Test User")
      expect(response.body).to include("Some product")
      expect(response.body).to include("Some category")
    end
  end

  describe "#edit" do
    include_context "existing_user"

    it "renders an edit form" do
      sign_in user

      get :edit, params: { id: user.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "#update" do
    include_context "existing_user"

    let!(:valid_params) {
      {
        "user" => {
          "available" => "1",
          "communities" => [""],
          "area_of_expertise_1" => "A - Leadership, RH, Opérations et Stratégie",
          "area_of_expertise_2" => "A - Leadership, RH, Opérations et Stratégie",
          "area_of_expertise_3" => "A - Leadership, RH, Opérations et Stratégie",
          "blitz_expertises" => [""],
          "slogan" => "",
          "special_need" => "",
          "ask_meeting_with" => "",
          "first_name" => "Updated",
          "last_name" => "User",
          "headline" => "Someone",
          "company" => "TestCompany",
          "username" => "talent_user",
          "email" => "talent@example.com",
          "phone" => "",
          "location" => "",
          "github_url" => "",
          "linkedin_url" => "",
          "web_site_url" => "",
          "interest_list" => "",
          "skill_list" => "Editing",
          "description" => "<p>test description</p>",
          "admin_notes" => ""
        },
        "id" => user.id.to_s
      }
    }

    it "updates the user" do
      sign_in user

      patch :update, params: valid_params

      user.reload

      expect(user.first_name).to eq("Updated")

      expect(response).to redirect_to(user_path(user))
    end
  end

  describe "#update_payment_information" do
    include_context "existing_user"

    let!(:valid_params) {
      {
        "stripe_temporary_token" => "tok_1JGR4EFiUwJySKD8WwzvqzZL",
        "id" => user.id.to_s
      }
    }

    it "updates the stripe customer source with the stripe temporary token passed from the stripe elements form" do
      sign_in user

      customer = double("customer")
      expect_any_instance_of(User).to receive(:stripe_customer).and_return(customer)
      expect(customer).to receive(:source=).with("tok_1JGR4EFiUwJySKD8WwzvqzZL")
      expect(customer).to receive(:save).and_return(true)

      patch :update_payment_information, params: valid_params

      expect(response).to be_successful
    end
  end

  describe "#destroy" do
    include_context "existing_user"

    it "allows a user to destroy their account" do
      sign_in user

      expect {
        delete :destroy, params: { id: user.id }
      }.to change(User, :count).by(-1)

      expect(User.find_by(id: user.id)).to eq(nil)

      expect(response).to redirect_to(users_path)
    end
  end

  describe "#accept_terms" do
    include_context "existing_user"

    it "renders a page for the user to accept the terms of the site" do
      user.update!(terms_accepted_at: false)

      sign_in user

      get :accept_terms, params: { "then" => "http://localhost:3000/invoices/new" }

      expect(response).to render_template(:accept_terms)
    end
  end

  describe "#accept_terms_for_current_user" do
    include_context "existing_user"

    it "accepts the terms for the current user" do
      user.update!(terms_accepted_at: false)

      sign_in user

      get :accept_terms_for_current_user,
          params: { "user" => { "terms_accepted_at" => "true", "then" => new_invoice_path } }

      user.reload

      expect(user.terms_accepted_at).to eq(true)
      expect(response).to redirect_to(new_invoice_path)
    end
  end

  describe "#resend_invitation" do
    include_context "existing_user"

    let!(:admin) { create :admin }
    before { sign_in admin }

    it "sends the user another invitation" do
      user.update!(invited_by: admin)

      get :resend_invitation, params: { id: user.id }

      expect(response).to redirect_to(user_path(user))
    end
  end

  describe "#fetch_user_data" do
    include_context "existing_user"

    let!(:admin) { create :admin }
    before { sign_in admin }

    it "fetches user data from google sheets" do
      expect_any_instance_of(GoogleSheetsToCollab).to receive(:call)

      post :fetch_user_data, params: { email: user.email }
    end
  end

  describe "#fetch_all_users_data" do
    let!(:admin) { create :admin }
    before { sign_in admin }

    it "fetches user data from google sheets" do
      expect_any_instance_of(GoogleSheetsToCollab).to receive(:call)

      post :fetch_all_users_data
    end
  end

  describe "#import_coachs" do
    let!(:admin) { create :admin }
    before { sign_in admin }

    it "imports coaches from google docs" do
      expect_any_instance_of(GoogleSheetsBlitzToCollab).to receive(:import_coachs).and_return({ messages: [] })

      post :import_coachs
    end
  end

  describe "#import_participants" do
    let!(:admin) { create :admin }
    before { sign_in admin }

    it "imports participants from google docs" do
      expect_any_instance_of(GoogleSheetsBlitzToCollab).to receive(:import_participants).and_return({ messages: [] })

      post :import_participants
    end
  end

  describe "#send_onboarding_message" do
    let!(:admin) { create :admin }
    before { sign_in admin }

    let!(:params) {
      {
        recipient: "recipient@example.com",
        title: "Your Onboarding Message",
        body: "Onboarding Message Body"
      }
    }

    it "sends an onboarding message" do
      expect(MessageMailer).to receive(:send_onboarding_message).and_call_original

      post :send_onboarding_message, params: params
    end
  end

  describe "#reset_card" do
    include_context "existing_user"

    before { sign_in user }

    it "resets the user's stripe credit card", vcr: true do
      customer = build_nested_object({
        id: "1",
        sources: {
          data: [
            {
              id: "2"
            }
          ]
        }
      })

      expect_any_instance_of(User).to receive(:stripe_customer).twice.and_return(customer)
      expect(Stripe::Customer).to receive(:delete_source).with("1", "2")

      get :reset_card, params: { "invoice_id" => "3" }

      expect(response).to redirect_to(invoice_path(3))
    end
  end
end
