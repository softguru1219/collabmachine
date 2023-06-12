require 'rails_helper'

describe UserDecorator do
  describe '#recent_projects' do
    it 'gives the recent projects with a message in the last day' do
      user = create(:user)
      mission = create(:mission)
      project = create(:project, user: user, missions: [mission])
      create(:message, item: mission, created_at: 23.hours.ago)
      expect(user.decorate.recent_projects).to include(project)
    end

    it 'does not give the old projects' do
      user = create(:user)
      mission = create(:mission)
      create(:project, user: user, missions: [mission])
      create(:message, item: mission, created_at: 25.hours.ago)
      expect(user.decorate.recent_projects).to eq([])
    end
  end
end
