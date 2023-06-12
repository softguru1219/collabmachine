require 'rails_helper'

describe MissionsController do
  shared_context "setup for #index and #show" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:project_created_by_user) do
      create(:project, user: user)
    end
    let!(:mission_created_by_user) do
      create(:mission, project: project_created_by_user, state: :started)
    end

    let!(:project_open_for_candidates) { create(:project, user: other_user) }
    let!(:mission_open_for_candidates) do
      create(:mission, project: project_open_for_candidates, state: :open_for_candidates)
    end

    let!(:project_assigned_to_user) { create(:project, user: other_user) }
    let!(:mission_assigned_to_user) do
      create(:mission, project: project_assigned_to_user, state: :started, applicants: [build(:applicant, user: user)])
    end
    before { sign_in user }
  end

  describe '#index' do
    include_context "setup for #index and #show"

    it 'gives all missions I can see by default' do
      get :index
      expect(response).to be_successful
    end
  end

  describe '#show' do
    include_context "setup for #index and #show"

    it 'shows a mission that is open for candidates' do
      get :show, params: { id: mission_open_for_candidates.to_param }
      expect(response).to be_successful
      expect(Mission.find_by(state: :open_for_candidates)).to eq(mission_open_for_candidates)
    end

    it 'shows a mission that is created by a user' do
      get :show, params: { id: mission_created_by_user.to_param }
      expect(response).to be_successful
      expect(Mission.find_by(state: :open_for_candidates)).to eq(mission_open_for_candidates)
    end
  end

  shared_context "one_existing_mission" do
    let!(:admin) { create :admin }
    let!(:user) { create :user }
    let!(:project) { create :project, user: user }
    let!(:mission) { create :mission, title: "original title", project: project }

    before { sign_in user }
  end

  describe "#edit" do
    include_context "one_existing_mission"

    it "should render the edit form" do
      get :edit, params: { id: mission.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "#update" do
    include_context "one_existing_mission"
    let!(:valid_params) {
      {
        "mission" => {
          "project_id" => project.id,
          "title" => "updated title",
          "description" => "<p>test description</p>",
          "tag_list" => "",
          "terms" => "",
          "rate" => "",
          "budget_min" => "",
          "budget_max" => "",
          "start_date" => "",
          "end_date" => "",
          "admin_notes" => ""
        },
        "id" => mission.id
      }
    }

    it "should update the mission" do
      patch :update, params: valid_params

      mission.reload

      expect(mission.title).to eq('updated title')
      expect(response).to redirect_to(mission_path(mission))
    end
  end

  describe "#destroy" do
    include_context "one_existing_mission"

    it "destroys the mission" do
      expect {
        delete :destroy, params: { id: mission.id }
      }.to change(Mission, :count).by(-1)

      expect(Mission.find_by(id: mission.id)).to eq(nil)
      expect(response).to redirect_to(project_path(mission.project))
    end
  end

  describe "#mark_mission_reviewed" do
    include_context "one_existing_mission"

    it "marks the mission as reviewed" do
      sign_in admin

      mission.update!(state: "for_review")

      get :mark_mission_reviewed, params: { id: mission.id }

      expect(mission.reload.state).to eq("reviewed")
      expect(response).to redirect_to(mission_path(mission))
    end
  end

  describe "#open_mission_for_candidates" do
    include_context "one_existing_mission"

    it "marks the mission as opened for candidates" do
      mission.update!(state: "reviewed")

      get :open_mission_for_candidates, params: { id: mission.id }

      expect(mission.reload.state).to eq("open_for_candidates")
      expect(response).to redirect_to(mission_path(mission))
    end
  end

  describe "#submit_mission_for_review" do
    include_context "one_existing_mission"

    it "marks the mission as for review" do
      mission.update!(state: "draft")

      get :submit_mission_for_review, params: { id: mission.id }

      expect(mission.reload.state).to eq("for_review")
      expect(response).to redirect_to(mission_path(mission))
    end
  end

  describe "#start" do
    include_context "one_existing_mission"

    it "marks the mission as started" do
      mission.update!(state: "assigned")

      get :start, params: { id: mission.id }

      expect(mission.reload.state).to eq("started")
      expect(response).to redirect_to(mission_path(mission))
    end
  end

  describe "#finish" do
    include_context "one_existing_mission"

    it "marks the mission as finished" do
      mission.update!(state: "started")

      get :finish, params: { id: mission.id }

      expect(mission.reload.state).to eq("finished")
      expect(response).to redirect_to(mission_path(mission))
    end
  end

  describe "#reopen" do
    include_context "one_existing_mission"

    it "marks the mission as started" do
      mission.update!(state: "finished")

      get :reopen, params: { id: mission.id }

      expect(mission.reload.state).to eq("started")
      expect(response).to redirect_to(mission_path(mission))
    end
  end

  describe "#archive" do
    include_context "one_existing_mission"

    it "marks the mission as archived" do
      mission.update!(state: "finished")

      get :archive, params: { id: mission.id }

      expect(mission.reload.state).to eq("archived")
      expect(response).to redirect_to(mission_path(mission))
    end
  end

  describe "#hold" do
    include_context "one_existing_mission"

    it "marks the mission as on hold" do
      mission.update!(on_hold: false)

      get :hold, params: { id: mission.id }

      expect(mission.reload.on_hold).to eq(true)
      expect(response).to redirect_to(mission_path(mission))
    end
  end

  describe "#sort" do
    let!(:user) { create :user }
    let!(:mission_1) { build :mission }
    let!(:mission_2) { build :mission }
    let!(:project) { create :project, user: user, missions: [mission_1, mission_2] }

    before { sign_in user }

    it "rearranges the missions" do
      get :sort, params: { "mission" => [mission_2.id.to_s, mission_1.id.to_s] }

      expect(mission_1.reload.position).to eq(2)
      expect(mission_2.reload.position).to eq(1)
    end
  end

  describe "#slack_notify_new_mission", vcr: true do
    include_context "one_existing_mission"

    it "notifies slack of a new mission" do
      expect_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage).and_call_original

      post :slack_notify_new_mission, params: { id: mission.id }
    end
  end
end
