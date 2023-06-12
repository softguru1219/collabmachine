require 'rails_helper'

feature 'User message' do
  let(:client) { create(:user) }
  let(:admin) { create(:admin) }

  context 'Visitor' do
    scenario 'Send a feedback' do
      send_a_recommendation

      expect(page).to have_current_path(root_path)
    end
  end

  context 'Client' do
    before do
      sign_in(client)
    end

    scenario 'Send a feedback' do
      insert_dashboard_seed_data
      send_a_recommendation

      expect(page).to have_current_path(dashboard_path)
      expect(page).to have_content 'The message was successfully submited. Thank you for your input.'
    end

    scenario 'Cannot see all the messages' do
      visit user_messages_path

      expect(page).to have_content 'You cannot perform this action.'
    end
  end

  context 'Admin' do
    before do
      sign_in(admin)
    end

    scenario 'Can see all the messages' do
      create_a_message
      visit user_messages_path

      expect(page).to have_content 'Recommendation'
    end

    scenario 'edit a message' do
      create_a_message
      visit user_messages_path

      click_on 'Recommendation'
      click_on 'Edit message'

      fill_in 'Title', with: 'Recommendation2'
      click_on 'Save'

      expect(page).to have_content 'Recommendation2'
    end

    scenario 'delete a message' do
      insert_dashboard_seed_data

      create_a_message
      visit user_messages_path

      click_on 'Recommendation'
      click_on 'Delete message'

      expect(page).to have_content 'The message was successfully destroyed.'
    end
  end

  def create_a_message
    create(:user_message)
  end

  def send_a_recommendation
    visit feedback_path

    fill_in 'Title', with: 'Recommendation'
    fill_in 'Message', with: 'Hi, this is a recommendation'

    click_on 'Save'
  end
end
