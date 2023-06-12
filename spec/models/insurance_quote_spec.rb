require 'rails_helper'

RSpec.describe InsuranceQuote, type: :model do
  describe " Validations" do
    it " has a valid name" do
      test = InsuranceQuote.create(
        name: "",
        email: "sample@gmail.com",
        phone: "PhoneNumber"
      )
      expect(test).not_to be_valid
      test.name = "Name"
      expect(test).to be_valid
    end

    it " has a valid email" do
      test = InsuranceQuote.create(
        name: "Name",
        email: "",
        phone: "PhoneNumber"
      )
      expect(test).not_to be_valid
      test.email = "sample@gmail.com"
      expect(test).to be_valid
    end

    it " has a valid phone" do
      test = InsuranceQuote.create(
        name: "Name",
        email: "sample@gmail.com",
        phone: ""
      )
      expect(test).not_to be_valid
      test.phone = "PhoneNumber"
      expect(test).to be_valid
    end
  end
end
