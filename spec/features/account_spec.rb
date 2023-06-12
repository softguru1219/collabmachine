require 'rails_helper'

feature 'Account', :vcr do
  let(:user) { create(:user) }
  before { insert_dashboard_seed_data }

  scenario 'Create a new account' do
    visit root_path
    click_on 'Sign up'

    fill_in 'user_email', with: 'john@example.com'
    fill_in 'user_password', with: 'qwerty'
    fill_in 'user_password_confirmation', with: 'test'
    click_on 'Submit'

    expect(page).to have_content "Password confirmation doesn't match Password"

    fill_in 'user_email', with: 'john@example.com'

    # fill_in 'user_first_name', with: 'John'
    # fill_in 'user_last_name', with: 'Smith'

    fill_in 'user_password', with: 'qwerty'
    fill_in 'user_password_confirmation', with: 'qwerty'
    click_on 'Submit'

    expect(page).to have_content "Don't hesitate to put as much details as you want on your profie and we'll let you know when your account will be ready to use."

    sign_in(user)
    visit dashboard_path
    click_on 'Members'

    expect(page).to have_css("table.users tbody tr", count: 3)
    expect(page).to have_content("john@example.com")
  end

  scenario 'Edit of simple text fields' do
    attribute_names = [
      'first_name', 'last_name', 'headline', 'company', 'username', 'email'
    ]

    sign_in(user)
    visit root_path
    find('.avatar').click
    click_on 'Profile'
    click_on('Edit profile', match: :first)
    fields = user.attributes.slice(*attribute_names)
    fields.each do |field, new_value|
      label = User.human_attribute_name(field.to_sym)
      expect(page).to have_field(label, with: user.send(field))
      fill_in(label, with: new_value)
    end
    click_on 'Save'

    expect(page).to have_content 'Profile was successfully updated.'
    expect(user.reload.slice(*attribute_names)).to eq(fields)
  end
end
