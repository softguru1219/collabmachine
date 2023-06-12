require 'rails_helper'

describe Mission, vcr: true do
  let(:user) { create(:user) }
  let!(:first_mission) { create(:mission) }

  before do
    create(:mission, state: "assigned")
    create(:mission)
  end

  describe 'by state' do
    it 'can find all mission with a state ' do
      expect(Mission.count).to eq 3
      expect(Mission.by_state('assigned').count).to eq 1
      Mission.by_state('draft').last.update(state: 'assigned')
      expect(Mission.by_state('assigned').count).to eq 2
    end

    it 'can return an empty array in none match ' do
      expect(Mission.count).to eq 3
      expect(Mission.by_state('finished').count).to eq 0
    end
  end

  describe 'by assignee' do
    let(:applicant) { create(:applicant, user: user, mission: first_mission) }

    it 'can find all mission assigned to a certain user' do
      applicant.update(state: 'assigned')

      expect(Mission.count).to eq 3
      expect(Mission.by_assignee(user.id).count).to eq 1
    end

    it 'can return an empty array in none match ' do
      applicant.update(state: 'rejected')

      expect(Mission.count).to eq 3
      expect(Mission.by_assignee(user.id).count).to eq 0
    end
  end

  describe 'by user' do
    let(:project) { create(:project, user: user) }

    it 'can find all mission owned by a user' do
      expect(project.missions.count).to eq 1
      expect(Mission.count).to eq 4
      expect(Mission.by_user(user.id).count).to eq 1
    end

    it 'can return an empty array in none match ' do
      project.missions[0].update(project: nil)

      expect(Mission.count).to eq 4
      expect(Mission.by_user(user.id).count).to eq 0
    end
  end
end
