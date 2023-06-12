require 'rails_helper'

RSpec.describe Message do
  subject {
    described_class.new(
      sender: 1,
      recipient: 2,
      audience: 'public',
      subject: 'Message Subject'
    )
  }

  describe "Validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a audience" do
      subject.audience = nil
      expect(subject).to_not be_valid
    end

    it "is not valid without a subject" do
      subject.subject = nil
      expect(subject).to_not be_valid
    end
  end
end
