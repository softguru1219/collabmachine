require 'rails_helper'

describe User, vcr: true do
  let!(:user) { create(:user, interest_list: ['test_interest'], skill_list: ['test_skill']) }

  before do
    create(:canditate)
    create(:admin)
  end

  describe 'by name' do
    it 'can query with first name' do
      expect(User.count).to eq 3
      expect(User.by_name('John').count).to eq 1
    end

    it 'can query with last name' do
      expect(User.count).to eq 3
      expect(User.by_name('Doe').count).to eq 1
    end

    it 'can query with email ' do
      expect(User.count).to eq 3
      expect(User.by_name('@example.com').count).to eq 3
    end

    it 'can query with username' do
      expect(User.count).to eq 3
      expect(User.by_name('talent').count).to eq 1
    end

    it 'can query with company' do
      expect(User.count).to eq 3
      expect(User.by_name('TestCompany').count).to eq 1
    end
  end

  describe 'by tag' do
    it 'can query all with no tag' do
      expect(User.count).to eq 3
      expect(User.by_tags([]).count).to eq 3
    end

    it 'can query 1 with interest tag' do
      expect(User.count).to eq 3
      expect(User.by_tags(['test_interest']).count).to eq 1
    end

    it 'can query 1 with skill tag' do
      expect(User.count).to eq 3
      expect(User.by_tags(['test_skill']).count).to eq 1
    end
  end

  describe 'by description' do
    it 'can query all with no description' do
      expect(User.count).to eq 3
      expect(User.by_description('').count).to eq 3
    end

    it 'can query 1 with a description' do
      expect(User.count).to eq 3
      expect(User.by_description('test').count).to eq 1
    end
  end

  describe 'by active state' do
    it 'can query active' do
      expect(User.count).to eq 3
      expect(User.by_active_state("active").count).to eq 3
    end

    it 'can query with inactive' do
      expect(User.count).to eq 3
      user.update(active: false)
      expect(User.by_active_state("inactive").count).to eq 1
      user.update(active: true)
      expect(User.by_active_state("inactive").count).to eq 0
    end
  end

  describe 'by type' do
    before do
      create(:company)
    end

    it 'can query personal' do
      expect(User.count).to eq 4
      expect(User.by_type("personal").count).to eq 3
    end

    it 'can query company' do
      expect(User.count).to eq 4
      expect(User.by_type("company").count).to eq 1
    end
  end
end
