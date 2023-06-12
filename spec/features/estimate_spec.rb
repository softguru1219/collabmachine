require 'rails_helper'

feature 'Project' do
  scenario 'An admin can view estimates' do
    create(:estimate, title: 'My Estimate')

    sign_in(create(:user, access_level: 'admin'))
    visit estimates_path
    expect(page).to have_content('My Estimate')
  end

  scenario 'An admin can view an estimate' do
    estimate = create(:estimate, title: 'My Estimate')

    sign_in(create(:user, access_level: 'admin'))
    visit estimate_path(estimate)
    expect(page).to have_content('My Estimate')
  end

  scenario 'Ask for an estimate' do
    visit new_estimate_path

    fill_in 'estimate_email', with: 'dummy@dummy.com'
    fill_in 'estimate_title', with: 'Title'
    fill_in 'estimate_description', with: 'description'
    click_on 'Send'

    expect(page).to have_content 'Your estimate has been created'
  end

  scenario 'An admin delete an estimate' do
    estimate = create(:estimate, title: 'My Estimate')

    sign_in(create(:user, access_level: 'admin'))
    visit estimates_path

    within("#estimate-#{estimate.id}") do
      click_on 'Destroy'
    end

    expect(page).to have_content 'Estimate was successfully destroyed'
    expect(page).to_not have_content('My Estimate')
  end
end
