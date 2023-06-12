require "pundit/rspec"

describe MissionPolicy do
  subject { described_class }

  # TODO: to be continued...

  permissions :index? do
    it "grants access if mission is mine or is admin" do
      expect(subject).to permit(User.new(access_level: 'admin'), Mission.new)
    end
  end
end
