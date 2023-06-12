require 'rails_helper'

describe ApplicantsController do
  render_views

  let!(:client) { create :user }
  let!(:talent) { create :user }
  let!(:other_talent) { create :user }
  let!(:project) { create :project, user: client }
  let!(:mission) { create :mission, project: project, state: "open_for_candidates" }

  describe "#toggle_im_interested" do
    before { sign_in talent }

    it "applies to the mission if the talent isn't already applied" do
      post :toggle_im_interested_to_mission, params: { mission_id: mission.id }, format: :js

      mission.reload

      applicant = mission.applicants.first
      expect(applicant.user).to eq(talent)

      expect(response).to be_successful
    end

    it "unapplies to the mission if the talent is already applied" do
      create :applicant, mission: mission, user: talent

      post :toggle_im_interested_to_mission, params: { mission_id: mission.id }, format: :js

      mission.reload

      expect(mission.applicants).to eq([])

      expect(response).to be_successful
    end
  end

  # TODO: this is action is currently allowed for common users, but it rejects all existing applicants
  # seems like it may be a bug?
  # will need to test the conditional branches more rigorously once behaviour is clarified
  describe "#admin_set_applicant" do
    before { sign_in talent }

    let!(:params) {
      {
        user_id: other_talent.id,
        mission_id: mission.id,
        pointed_by: talent.id
      }
    }

    it "applies another user to the mission" do
      post :admin_set_applicant, params: params, format: :js

      mission.reload

      applicant = mission.applicants.last

      expect(applicant.user).to eq(other_talent)
      expect(applicant.state).to eq("suggested")
    end
  end

  describe "#destroy_suggestions" do
    before { sign_in talent }

    let!(:talent_suggestion) { create :applicant, user: talent, mission: mission, state: "suggested" }
    let!(:other_talent_suggestion) { create :applicant, user: other_talent, mission: mission, state: "suggested" }

    it "destroys suggestions for the mission for the current user" do
      get :destroy_suggestions, params: { mission_id: mission.id }

      mission.reload

      expect(mission.applicants).to eq([other_talent_suggestion])

      expect(response).to redirect_to(mission_path(mission))
    end
  end

  # TODO: test more branches/more in depth
  describe "#set_applicant_state" do
    before { sign_in client }
    let!(:applicant) { create :applicant, user: talent, mission: mission, state: "suggested" }

    it "changes the applicant state" do
      post :set_applicant_state,
           params: { "id" => applicant.id.to_s, "state" => "assigned", "mission_id" => mission.id.to_s, "locale" => "en" },
           format: :js

      expect(applicant.reload.state).to eq("assigned")

      expect(response).to be_successful
    end
  end
end
