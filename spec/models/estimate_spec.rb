require 'rails_helper'

RSpec.describe Estimate, type: :model do
  describe "Validations" do
    it "has a title" do
      estimate = Estimate.create(
        title: "",
        description: "description",
        email: "title@gmail.com",
        phone: "123456"
)
      expect(estimate).not_to be_valid
      estimate.title = "title"
      expect(estimate).to be_valid
    end

    it "has a description" do
      estimate = Estimate.create(
        title: "title",
        description: "",
        email: "estimate@gmail.com",
        phone: "123456"
)
      expect(estimate).not_to be_valid
      estimate.description = "description"
      expect(estimate).to be_valid
    end

    it "has a email if phone is empty" do
      estimate = Estimate.create(
        title: "title",
        description: "description",
        email: "",
        phone: ""
)
      expect(estimate).not_to be_valid
      estimate.email = "estimate@gmail.com"
      expect(estimate).to be_valid
    end

    it "has a phone if email is empty" do
      estimate = Estimate.create(
        title: "title",
        description: "description",
        email: "",
        phone: ""
)
      expect(estimate).not_to be_valid
      estimate.phone = "123456"
      expect(estimate).to be_valid
    end
  end
end
