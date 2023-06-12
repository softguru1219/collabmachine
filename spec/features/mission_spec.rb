require 'rails_helper'

feature 'Mission' do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }

  background { sign_in(user) }

  scenario 'View projects' do
    create(:mission, title: 'Mission Title', project: project, applicants: [build(:applicant, user: user)])

    visit missions_path

    expect(page).to have_content('Mission Title')
  end
end
