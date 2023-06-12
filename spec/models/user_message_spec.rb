require 'rails_helper'

RSpec.describe UserMessage, type: :model do
  let(:user) { create(:user) }

  describe "Validations" do
    it " has a title" do
      test = UserMessage.create(
        title: "",
        message: "It is A Message",
        user: user
      )
      expect(test).not_to be_valid
      test.title = "title"
      expect(test).to be_valid
    end

    it " has a title with valid maximum length" do
      long_title = "This is a message for the test. This is a message for the test.
      This is a message for the test. This is a message for the test."

      test = UserMessage.create(
        title: long_title[0...101],
        message: "It is A Message",
        user: user
      )
      expect(test).not_to be_valid
      test.title = long_title[0...100]
      expect(test).to be_valid
    end

    it " has a message" do
      test = UserMessage.create(
        title: "Title",
        message: "",
        user: user
      )
      expect(test).not_to be_valid
      test.message = "It is A Message"
      expect(test).to be_valid
    end
  end

  describe "Delegation for"

  it " firstname and lastname with prefix user" do
    test = UserMessage.create(
      title: "Title",
      message: "It is A Message",
      user: user
    )
    expect(test.user_first_name).to be_eql(test.user.first_name)
    expect(test.user_last_name).to be_eql(test.user.last_name)
  end
end
