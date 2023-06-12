require "pundit/rspec"

describe MessagePolicy do
  subject { described_class }

  permissions :index? do
    it "grants access if message is mine or is admin" do
      expect(subject).to permit(User.new(access_level: 'admin'), Message.new)
    end

    it "it grants access if message is public" do
      expect(subject).to permit(User.new, Message.new(audience: 'public'))
    end

    it "it grants access if message is recipient is assigned" do
      # TODO: create an applicant be this user
      expect(subject).to permit(User.new, Message.new(audience: 'public'))
    end
  end

  permissions :create? do
    # TODO: make tests
  end

  permissions :update? do
    # TODO: make tests
  end

  permissions :destroy? do
    # TODO: make tests
  end
end
