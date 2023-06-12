require 'rails_helper'

feature 'Project' do
  let(:user) { create(:user) }
  let(:mission) { create(:mission, title: 'Mission Title') }

  background { sign_in(user) }

  scenario 'View projects' do
    create(:project, title: 'Project Title', missions: [mission], user: user)

    visit projects_path

    expect(page).to have_content('Project Title')
    expect(page).to have_content('Mission Title')
  end

  scenario 'Create a new project' do
    visit projects_path

    first('.new-project').click
    expect(page).to have_content 'Project details'

    fill_in 'project_title', with: 'The new project title'
    fill_in 'project_description', with: 'Description'
    click_on 'Save'

    expect(page).to have_content 'Project was successfully created.'
  end

  scenario 'Submit a project' do
    visit projects_path

    first('.new-project').click
    expect(page).to have_content 'Project details'

    fill_in 'project_title', with: 'The new project title2'
    fill_in 'project_description', with: 'Description'
    click_on 'Submit'

    expect(page).to have_content 'Project was successfully created.'
    expect(page).to have_content 'Mission for project The new project title2'
  end
end
