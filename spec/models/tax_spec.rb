require 'rails_helper'

RSpec.describe Tax, type: :model do
  let(:user) { create(:user) }

  describe "Validations" do
    it "tax has a name" do
      tax = Tax.new(
        name: '',
        rate: 1,
        user: user
      )
      expect(tax).not_to be_valid
      tax.name = 'tax has a name'
      expect(tax).to be_valid
    end

    it "tax has a rate" do
      tax = Tax.new(
        name: 'name',
        rate: '',
        user: user
      )
      expect(tax).not_to be_valid
      tax.rate = 1
      expect(tax).to be_valid
    end

    it "tax has a valid rate" do
      nine_precition_rate = 999999.99
      tax = Tax.new(
        name: 'name',
        rate: nine_precition_rate,
        user: user
      )
      expect(tax).to be_valid
      tax.rate = nine_precition_rate + 1
      expect(tax).to be_valid
    end
  end

  describe "#description" do
    it "should be equal with the valid string" do
      tax = Tax.new(
        name: 'name',
        rate: 1.0,
        number: nil,
        user: user
      )
      expect(tax.description).not_to eq("name 1.0% (1)")
      tax.number = 1
      expect(tax.description).to eq("name 1.0% (1)")
    end
  end

  describe "#rate_as_decimal" do
    it "should be valid" do
      tax = Tax.new(
        name: 'name',
        rate: 0,
        user: user
      )
      expect(tax.rate_as_decimal).not_to be > 0
      tax.rate += 1
      expect(tax.rate_as_decimal).to be > 0
    end
  end
end
