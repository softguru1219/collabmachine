require 'rails_helper'

describe ProjectsController, type: :controller do
  render_views

  describe 'GET #index' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:project_created_by_user) do
      create(:project, user: user, missions: [create(:mission)])
    end
    let!(:project_open_for_candidates) { create(:project, user: other_user) }
    let!(:project_assigned_to_user) { create(:project, user: other_user) }
    let!(:mission_open_for_candidates) do
      create(:mission, project: project_open_for_candidates, state: :open_for_candidates)
    end
    let!(:mission_assigned_to_user) do
      create(:mission, project: project_assigned_to_user, state: :started, applicants: [build(:applicant, user: user)])
    end

    before { sign_in user }

    it 'gives all projects I can see by default' do
      get :index

      expect(assigns(:projects)).to include project_created_by_user
      expect(assigns(:projects)).to include project_open_for_candidates
      expect(assigns(:projects)).to include project_assigned_to_user
    end

    context 'with audience is private' do
      it 'gives projects where I am concerned' do
        get :index, params: { audience: :private }

        expect(assigns(:projects)).to include project_created_by_user
        expect(assigns(:projects)).to_not include project_open_for_candidates
        expect(assigns(:projects)).to include project_assigned_to_user
      end
    end

    context 'with audience is public' do
      it 'gives public projects' do
        get :index, params: { audience: :public }

        expect(assigns(:projects)).to_not include project_created_by_user
        expect(assigns(:projects)).to include project_open_for_candidates
        expect(assigns(:projects)).to_not include project_assigned_to_user
      end
    end
  end

  shared_context "existing_project" do
    let!(:user) { create :user, first_name: "Project", last_name: "Creator" }
    let!(:applicant_user) { create :user, first_name: "Some", last_name: "Applicant" }
    let!(:project) { create :project, user: user, title: "Test Project", description: "Test Project Description" }
    let!(:mission) { create :mission, project: project, title: "Some Mission" }
    let!(:applicant) { create :applicant, mission: mission, state: "assigned", user: applicant_user }
    before {
      mission.tag_list.add("a_tag")
      mission.save!
    }
  end

  describe "#show" do
    include_context "existing_project"

    before { sign_in user }

    it "shows the project" do
      get :show, params: { id: project.id }

      expect(response.body).to include("Test Project")
      expect(response.body).to include("Some Applicant")
      expect(response.body).to include("Project Creator")
      expect(response.body).to include("Some Mission")
      expect(response.body).to include("Some Applicant")
      expect(response.body).to include("a_tag")
    end

    it "shows an event-type project" do
      mock_google_sheets_blitz_to_collab_api_calls

      project.update!(project_type: "event")

      get :show, params: { id: project.id }

      expect(response.body).to include("Test Project Description")
    end
  end

  describe "#new" do
    let!(:user) { create :user }
    before { sign_in user }

    it "renders the form for a new project" do
      get :new

      expect(response).to render_template(:new)
    end
  end

  let!(:valid_params) {
    {
      "project" => {
        "title" => "Test Project Title",
        "description" => "<p>Test Project Description</p>",
        "private_notes" => "<p>Test Project Private Notes</p>",
        "project_type" => "default",
        "visibility_scope" => "public",
        "user_id" => "0",
        "missions_attributes" => {
          "0" => {
            "title" => "mission 1 title",
            "description" => "<p>mission 1 description</p>",
            "budget_min" => "20",
            "budget_max" => "100",
            "start_date" => "2021-07-13",
            "end_date" => "2021-07-29",
            "_destroy" => "false"
          }
        }
      }
    }
  }

  let!(:valid_admin_params) {
    admin_specific_params = {
      "admin_notes" => "<p>some admin notes</p>",
      "admin_client" => "",
      "admin_client_summary" => "",
      "admin_references_links" => "",
      "admin_project_type" => "",
      "admin_talents_resources" => "",
      "admin_budget" => "",
      "admin_delivery" => "",
      "admin_position_in_process" => "",
      "admin_extra_info" => ""
    }

    valid_admin_params = valid_params.deep_dup
    valid_admin_params["project"] = valid_admin_params["project"].merge(admin_specific_params)

    valid_admin_params
  }

  describe "#create" do
    let!(:user) { create :user }
    let!(:admin) { create :admin }

    it "allows an admin to create a project for a user" do
      valid_admin_params["project"]["user_id"] = user.id.to_s

      sign_in admin

      expect {
        post :create, params: valid_admin_params
      }.to change(Project, :count).by(1)

      project = Project.last

      expect(project.title).to eq("Test Project Title")
      expect(project.description).to eq("<p>Test Project Description</p>")
      expect(project.private_notes).to eq("<p>Test Project Private Notes</p>")
      expect(project.project_type).to eq("default")
      expect(project.visibility_scope).to eq("public")
      expect(project.user).to eq(user)
      expect(project.admin_notes).to eq("<p>some admin notes</p>")

      mission = project.missions.first

      expect(mission.title).to eq("mission 1 title")
      expect(mission.description).to eq("<p>mission 1 description</p>")
      expect(mission.budget_min).to eq(20)
      expect(mission.budget_max).to eq(100)
      expect(mission.start_date).to eq(Date.new(2021, 7, 13))
      expect(mission.end_date).to eq(Date.new(2021, 7, 29))
    end

    it "allows a user to create a project for themselves" do
      valid_params["project"]["user_id"] = user.id.to_s

      sign_in user

      expect {
        post :create, params: valid_params
      }.to change(Project, :count).by(1)

      project = Project.last

      expect(project.title).to eq("Test Project Title")
      expect(project.description).to eq("<p>Test Project Description</p>")
      expect(project.private_notes).to eq("<p>Test Project Private Notes</p>")
      expect(project.project_type).to eq("default")
      expect(project.visibility_scope).to eq("public")
      expect(project.user).to eq(user)

      mission = project.missions.first

      expect(mission.title).to eq("mission 1 title")
      expect(mission.description).to eq("<p>mission 1 description</p>")
      expect(mission.budget_min).to eq(20)
      expect(mission.budget_max).to eq(100)
      expect(mission.start_date).to eq(Date.new(2021, 7, 13))
      expect(mission.end_date).to eq(Date.new(2021, 7, 29))
    end

    it "rerenders the form if it has invalid params" do
      valid_admin_params["project"]["user_id"] = user.id.to_s
      valid_admin_params["project"]["title"] = nil

      sign_in admin

      expect {
        post :create, params: valid_admin_params
      }.to_not change(Project, :count)

      expect(response).to render_template(:new)
    end
  end

  describe "#edit" do
    include_context "existing_project"

    it "renders a project edit page" do
      sign_in user

      get :edit, params: { id: project.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "#update" do
    include_context "existing_project"

    it "allows a user to update the project" do
      sign_in user

      valid_params["id"] = project.id.to_s
      valid_params["project"]["user_id"] = user.id.to_s
      valid_params["project"]["title"] = "Updated Project Title"

      patch :update, params: valid_params

      expect(response).to redirect_to(project_path)
      expect(project.reload.title).to eq("Updated Project Title")
    end
  end

  describe "#destroy" do
    include_context "existing_project"

    it "allows a user to destroy their project" do
      sign_in user

      delete :destroy, params: { id: project.id }

      expect(response).to redirect_to(missions_path)
      expect(Project.find_by(id: project.id)).to eq(nil)
    end
  end

  describe "#hold" do
    include_context "existing_project"

    it "allows a user to destroy their project" do
      sign_in user

      project.update!(on_hold: false)
      project.missions.all { |m| m.update!(on_hold: false) }

      get :hold, params: { id: project.id }

      expect(project.reload.on_hold).to eq(true)
      expect(project.missions.all? { |m| m.reload.on_hold? }).to eq(true)

      expect(response).to redirect_to(project_path(project))
    end
  end
end
