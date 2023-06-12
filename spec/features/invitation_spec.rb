require "rails_helper"

feature 'Inviting users' do
  let!(:admin) { create :admin }
  before { insert_dashboard_seed_data }

  scenario 'An admin can invite users, and the user can accept the invitation', js: true do
    sign_in admin

    visit dashboard_path

    click_on "Send invites", match: :first

    fill_in "First Name", with: "Test"
    fill_in "Last Name", with: "User"
    fill_in "Email", with: "test@user.com"

    click_on "Send an invitation"

    find "*", text: "An invitation email has been sent to test@user.com", match: :first

    sign_out :user

    email = ActionMailer::Base.deliveries.last
    html = Nokogiri::HTML(email.html_part.body.to_s)
    acceptance_url = html.at("a:contains('Accept invitation')")['href']
    acceptance_path = URI::parse(acceptance_url).request_uri

    visit acceptance_path

    fill_in "Password", with: "asdfasdf123"
    fill_in "Confirm password", with: "asdfasdf123"

    click_on "Set my password"

    find "*", text: "Your password was set successfully. You are now signed in.", match: :first
  end
end
