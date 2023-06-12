require 'rails_helper'

describe DashboardController do
  render_views

  let!(:user) { create :user }
  let!(:admin) { create :admin }

  describe "#index" do
    before { sign_in user }
    before { insert_dashboard_seed_data }
    let!(:referred_user) { create :user, first_name: "Referred", last_name: "User", invited_by: user }
    let!(:created_project) { create :project, user: user, title: "Project Created by User" }
    let!(:assigned_project_creator) { create :user }
    let!(:assigned_project) { create :project, user: assigned_project_creator, title: "Project Assigned To User" }
    let!(:assigned_mission) { create :mission, project: assigned_project }
    let!(:applicant) { create :applicant, user: user, mission: assigned_mission }
    let!(:project_with_open_mission_creator) { create :user }
    let!(:project_with_open_mission) { create :project, user: project_with_open_mission_creator, title: "Project With Open Mission" }
    let!(:open_mission) { create :mission, project: project_with_open_mission, state: "open_for_candidates" }

    it "renders the dashboard" do
      get :index

      expect(response).to render_template(:index)
      expect(response.body).to include("Referred User")
      expect(response.body).to include("Project Created by User")
      expect(response.body).to include("Project Assigned To User")
      expect(response.body).to include("Project With Open Mission")
    end
  end

  describe "#metrics" do
    before { sign_in admin }

    let!(:talent) { create(:user).tap { |u| u.meta_attributes.create!(name: "is:talent") } }
    let!(:client) { create(:user).tap { |u| u.meta_attributes.create!(name: "is:client") } }
    let!(:project) { create(:project, user: client) }

    it "renders the metrics page" do
      get :metrics
      expect(response).to render_template(:metrics)
    end
  end

  describe "#slack_users" do
    let!(:slack_user) { create :user, email: "test@user.com", first_name: "Slack", last_name: "UserAccount" }

    before { sign_in admin }

    it "shows slack users" do
      slack_api_response = build_nested_object({
        members: [
          {
            is_bot: false,
            team: "ABC",
            profile: {
              email: "test@user.com"
            }
          }
        ]
      })

      expect_any_instance_of(Slack::Web::Client).to receive(
        :users_list
      ).with(presence: true, limit: 10).and_yield(slack_api_response)

      get :slack_users

      expect(response).to render_template(:slack_users)
      expect(response.body).to include("Slack UserAccount")
    end
  end

  describe "#missions" do
    before { sign_in admin }
    let!(:project) { create :project, user: user }
    let!(:mission) { create :mission, project: project, title: "Some Secret Mission" }

    it "shows a listing of missions" do
      get :missions

      expect(response).to render_template(:missions)
      expect(response.body).to include("Some Secret Mission")
    end
  end

  describe "#users" do
    before { sign_in admin }
    let!(:expected_user) { create :user, first_name: "Expected", last_name: "User" }

    it "renders a list of users" do
      get :users

      expect(response).to render_template(:users)
      expect(response.body).to include("Expected User")
    end
  end

  describe "#participation_system" do
    before { sign_in user }

    it "renders the participation system page" do
      get :participation_system

      expect(response).to render_template(:participation_system)
    end
  end

  describe "#master_service_agreement" do
    before { sign_in user }

    it "renders the master service agreement page" do
      get :master_service_agreement

      expect(response).to render_template(:master_service_agreement)
    end
  end

  # TODO: no template provided
  # describe "#get_contract_data" do
  #   before{ sign_in user }

  #   it "renders contract data" do
  #     get :get_contract_data, xhr: true

  #     expect(response).to render_template(:get_contract_data)
  #   end
  # end

  describe "#participants" do
    before { sign_in user }

    it "renders the participants page" do
      mock_google_sheets_blitz_to_collab_api_calls

      get :participants

      expect(response).to render_template(:participants)
    end
  end

  describe "#coachs" do
    before { sign_in user }

    it "renders the coachs page" do
      mock_google_sheets_blitz_to_collab_api_calls

      get :coachs

      expect(response).to render_template(:coachs)
    end
  end

  describe "#meeting_participants" do
    before { sign_in user }

    it "renders the meeting_participants page" do
      mock_google_sheets_blitz_to_collab_api_calls

      get :meeting_participants

      expect(response).to render_template(:meeting_participants)
    end
  end

  describe "#meet" do
    before { sign_in user }

    it "renders a page for people to meet" do
      mock_google_sheets_blitz_to_collab_api_calls

      get :meet, params: { room: "ABCD" }

      expect(response).to render_template(:meet)
    end
  end

  describe "#blitz_logs" do
    before { sign_in user }

    let!(:tracker) { create :tracker }

    it "renders logs of meetings" do
      get :blitz_logs

      expect(response).to render_template(:blitz_logs)
    end
  end
end
