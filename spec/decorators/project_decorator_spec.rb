require 'rails_helper'

describe ProjectDecorator do
  describe '#submit_review_confirm_message' do
    context 'when the project have unsubmitted missions' do
      it 'gives a message' do
        mission = Mission.new(state: 'draft')
        project = Project.new(missions: [mission]).decorate

        expect(project.submit_review_confirm_message).to match 'All the missions'
      end
    end

    context 'when the project does not have missions' do
      it 'do not gives a message' do
        Mission.new
        project = Project.new(missions: []).decorate

        expect(project.submit_review_confirm_message).to be_nil
      end
    end

    context 'when all the missions of the project are submitted' do
      it 'do not gives a message' do
        mission = Mission.new(state: 'for_review')
        project = Project.new(missions: [mission]).decorate

        expect(project.submit_review_confirm_message).to be_nil
      end
    end
  end

  describe '#recent_missions' do
    it 'gives the recent missions with a message in the last day' do
      user = create(:user)
      mission = create(:mission)
      project = create(:project, user: user, missions: [mission])
      create(:message, item: mission, created_at: 23.hours.ago)
      expect(project.decorate.recent_missions).to include(mission)
    end

    it 'does not give the old missions' do
      user = create(:user)
      mission = create(:mission)
      project = create(:project, user: user, missions: [mission])
      create(:message, item: mission, created_at: 25.hours.ago)
      expect(project.decorate.recent_missions).to eq([])
    end
  end
end
