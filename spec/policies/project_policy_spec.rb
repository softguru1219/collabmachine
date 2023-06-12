require "rails_helper"

describe ProjectPolicy do
  subject { described_class }

  # TODO: to be continued.

  permissions :index? do
    it "grants access if project is mine or is admin" do
      expect(subject).to permit(User.new(access_level: 'admin'), Project.new)
    end
  end

  describe "Scope" do
    let!(:user) { create :user, access_level: "freemium" }
    let!(:not_expected_project) { create :project, user: create(:user) }
    let(:scope) { Pundit.policy_scope!(user, Project) }

    it "shows the user projects which they have created" do
      created_project = create :project, user: user

      expect(scope.to_a).to eq([created_project])
    end

    it "shows the user projects with open missions" do
      project_with_open_mission = create :project, user: create(:user)
      create :mission, state: "open_for_candidates", project: project_with_open_mission

      expect(scope.to_a).to eq([project_with_open_mission])
    end

    it "shows the user projects they're assigned to" do
      assigned_project = create :project, user: create(:user)
      mission = create :mission, project: assigned_project
      create :applicant, mission: mission, user: user

      expect(scope.to_a).to eq([assigned_project])
    end
  end
end
