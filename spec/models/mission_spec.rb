require 'rails_helper'

describe Mission do
  let(:user) { create(:user) }
  subject {
    project = create(:project, user: user)
    described_class.new(
      title: 'A Project title here',
      description: 'Dummy desc',
      project: project
    )
  }

  describe "Validations" do
    it "mission titles should be set to default values" do
      mission = Mission.create
      expect(mission.title).to eq('Mission for project')
      mission = Mission.create(title: 'joie')
      expect(mission.title).to eq('joie')
    end
  end

  describe "Mission state" do
    it "is set to draft by default" do
      expect(subject.state).to eq('draft')
    end
  end

  describe "Flow" do
    it "goes from draft to archived" do
      subject.save
      subject.submit
      subject.review
      subject.invite_candidates
      create(:applicant, mission: subject, state: 'assigned', user: user)
      subject.assign
      subject.start
      subject.finish
      subject.archive
      expect(subject.state).to eq('archived')
    end
  end

  describe '#assigned_to' do
    it 'gives the projects with a mission assigned to a user' do
      user1 = create(:user)
      project1 = create(:project, user: user1)
      mission1 = create(:mission, project: project1)
      create(:applicant, mission: mission1, user: user1, state: "assigned")

      user2 = create(:user)
      project2 = create(:project, user: user2)
      mission2 = create(:mission, project: project2)
      create(:applicant, mission: mission2, user: user2, state: "assigned")

      expect(Mission.assigned_to(user1)).to eq([mission1])
      expect(Mission.assigned_to(user2)).to eq([mission2])
    end
  end

  describe ".by_search" do
    it "matches the mission title" do
      matching = create :mission, title: "Matching"
      _other = create :mission, title: "Other"

      expect(Mission.by_search("matching")).to eq([matching])
    end

    it "matches the mission description" do
      matching = create :mission, description: "Matching"
      _other = create :mission, description: "Other"

      expect(Mission.by_search("matching")).to eq([matching])
    end
  end
end
