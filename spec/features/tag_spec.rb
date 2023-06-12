require 'rails_helper'

feature 'Tag' do
  let(:user) {
    create(:user,
           interest_list: ['Interest-1', 'Interest-2'],
           skill_list: ['User Experience', 'Front-end'])
  }
  let(:admin) { create(:admin) }

  context 'User' do
    before do
      sign_in(user)
    end

    scenario 'see interests and skills on his profile' do
      insert_dashboard_seed_data
      visit dashboard_path
      click_on 'Profile'

      expect(page).to have_content('Skills')
      expect(page).to have_content('User Experience')
      expect(page).to have_content('Front-end')
      expect(page).to have_content('Interested in')
      expect(page).to have_content('Interest-1')
      expect(page).to have_content('Interest-2')
    end

    scenario 'edit skills and interests' do
      visit edit_user_path(user)

      fill_in  'Interest list', with: 'Interest-1'
      fill_in  'Skill list', with: 'User Experience'

      click_on 'Save'

      expect(page).to have_content('User Experience')
      expect(page).to have_content('Interest-1')

      expect(page).to_not have_content('Front-end')
      expect(page).to_not have_content('Interest-2')
    end
  end

  context 'Admin' do
    before do
      sign_in(admin)
    end

    scenario 'can edit skill of someone' do
      visit edit_user_path(user)

      fill_in  'Interest list', with: 'Interest-1'
      fill_in  'Skill list', with: 'User Experience'

      click_on 'Save'

      expect(page).to have_content('User Experience')
      expect(page).to have_content('Interest-1')

      expect(page).to_not have_content('Front-end')
      expect(page).to_not have_content('Interest-2')
    end

    scenario 'change the name of a tag' do
      visit edit_tag_path(user.interests.first)

      expect(page).to have_content 'Editing tag: Interest-1'

      fill_in 'Name', with: 'Interest-3005'
      click_on 'Update Tag'

      expect(page).to have_content 'Interest-3005'
    end

    scenario 'delete a tag', js: true do
      visit tag_path(user.interests.first)

      expect(page).to have_content 'Interest-1'

      click_on 'Delete tag'
      click_on 'OK'

      expect(page).to_not have_content 'Interest-1'
    end
  end
end
