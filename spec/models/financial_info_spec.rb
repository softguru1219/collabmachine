require 'rails_helper'

RSpec.describe FinancialInfo, type: :model do
  let(:user) { create(:user) }

  describe "Validation" do
    it "has a institution" do
      test = FinancialInfo.create(
        institution: "",
        transit: "Transit",
        account: "Account",
        user: user
      )
      expect(test).not_to be_valid
      test.institution = "Institution"
      expect(test).to be_valid
    end

    it "has a transit" do
      test = FinancialInfo.create(
        institution: "Institution",
        transit: "",
        account: "Account",
        user: user
      )
      expect(test).not_to be_valid
      test.transit = "Transit"
      expect(test).to be_valid
    end

    it "has a account" do
      test = FinancialInfo.create(
        institution: "Institution",
        transit: "Transit",
        account: "",
        user: user
      )
      expect(test).not_to be_valid
      test.account = "Account"
      expect(test).to be_valid
    end
  end

  describe "#description"
  it "should be equal with the valid string" do
    test = FinancialInfo.create(
      institution: "Institution",
      transit: "Transit",
      account: "Account",
      user: user
    )
    expect(test.description).not_to eq("")
    expect(test.description).to eq("Institution Transit Account")
  end
end
