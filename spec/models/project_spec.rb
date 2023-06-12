require 'rails_helper'

RSpec.describe Project do
  subject {
    described_class.new(
      user_id: 1,
      title: 'A project',
      description: 'description yeah'
    )
  }

  describe "Validations" do
    it "is not valid without a title" do
      subject.title = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without a Description" do
      subject.description = nil
      expect(subject).to_not be_valid
      subject.description = 'Fake description'
      expect(subject).to be_valid
    end

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a owner" do
      subject.user_id = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without a title" do
      subject.title = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without a description" do
      subject.description = nil
      expect(subject).to_not be_valid
    end

    it "should not create a default mission when manually creating a mission" do
      subject.missions.build(title: 'joie')
      subject.save
      expect(subject.missions.length).to eq(1)
    end

    it "should let us delete the only mission a project has" do
      subject.save
      subject.missions.first.destroy
      expect(subject.missions.length).to eql(1) # since it was the last one
      subject.missions.first.really_destroy!
      expect(subject.missions.first.really_destroyed?).to eql(true) # gone
    end
  end

  describe "Project state" do
    it "is set to draft by default" do
      expect(subject.state).to eq('draft')
    end
  end

  describe '#assigned_to' do
    it 'gives the projects with a mission assigned to a user' do
      user1 = create(:user)
      project1 = create(:project, user: user1)
      create(:mission, project: project1, applicants: [build(:applicant, user: user1)])

      user2 = create(:user)
      project2 = create(:project, user: user2)
      create(:mission, project: project2, applicants: [build(:applicant, user: user2)])

      expect(Project.assigned_to(user1)).to eq([project1])
      expect(Project.assigned_to(user2)).to eq([project2])
    end
  end
end
