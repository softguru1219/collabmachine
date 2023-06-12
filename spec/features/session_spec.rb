require 'rails_helper'

feature 'User session' do
  before { insert_dashboard_seed_data }

  scenario 'Do basic checking' do
    user = create(:user, email: 'john@example.com', password: "password")

    visit root_path
    click_on 'Log in'
    fill_in 'user_email', with: user.email
    click_on 'Log in'

    expect(page).to have_content 'Invalid Email or password'

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_on 'Log in'

    expect(page).to have_content 'Signed in successfully.'
    expect(page).to_not have_content 'Log in'
  end

  scenario 'Do basic checkout' do
    user = create(:user)
    sign_in(user)

    visit dashboard_path
    find('.avatar').click
    click_on 'Logout'

    expect(current_path).to eq root_path
    expect(page).to have_content 'Signed out successfully.'
  end
end
