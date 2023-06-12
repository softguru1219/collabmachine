require 'rails_helper'

feature 'Mission flow' do
  let(:client) { create(:user) }
  let(:canditate) { create(:canditate, access_level: "premium") }
  let(:admin) { create(:admin) }
  let(:project) { create(:project, user: client) }
  let(:mission) { create(:mission, project: project) }

  context 'Client' do
    before do
      sign_in(client)
    end

    scenario "Create a project, submit it and can't get canditates" do
      visit mission_path(mission)

      within_controls do
        expect(page).to have_content 'Submit (for review)'
      end
    end

    scenario "Submit a project for for review" do
      set_mission_state('draft')

      visit mission_path(mission)
      within_controls do
        click_on 'Submit (for review)'
      end

      expect(page).to have_content 'We review it all and come back to you shortly'
    end

    scenario 'create a project, submit it, got reviewed' do
      set_mission_state('reviewed')

      visit mission_path(mission)

      expect(page).to have_content 'Your mission has been approved, you can open for candidates or assign it directly.'
    end

    scenario 'choose a canditate to fulfill the mission', js: true do
      set_mission_state('open_for_candidates')
      make_the_canditate_apply

      visit mission_path(mission)
      click_on 'Applicant(s)'

      expect(page).to have_css('#applicants_listing table tbody tr', count: 1)

      select 'assigned', from: 'state'
      sleep(1) # give ajax request time to complete
      visit mission_path(mission)

      expect(page).to have_content("Assigned to\n#{canditate.first_name} #{canditate.last_name}")
    end

    scenario 'choose a member to fulfill the mission', js: true do
      set_mission_state('reviewed')

      visit mission_path(mission)
      click_on 'Assign to a member'

      click_on 'Choose a member'

      within ".dropdown-menu" do
        click_on "#{client.first_name} #{client.last_name}"
      end

      visit mission_path(mission,  locale: :en)

      expect(page).to have_content("Assigned to\n#{client.first_name} #{client.last_name}")
    end

    scenario 'can archive a mission with a paid invoice' do
      set_mission_state('finished')
      create_invoice(user: canditate, customer: client, missions: [mission])

      visit mission_path(mission)

      within_controls do
        expect(page).not_to have_content 'Close this mission'
      end

      create(:transaction, invoice: mission.invoices.first, paid: true)

      visit mission_path(mission)

      within_controls do
        expect(page).to have_content 'Close this mission'
      end
    end

    scenario "Put mission on hold" do
      set_mission_state('draft')

      visit mission_path(mission)
      within_controls do
        click_on 'Put this mission on hold'
      end

      expect(page).to have_content 'Draft - ON HOLD'
    end
  end

  context 'Admin' do
    before do
      sign_in(admin)
    end

    scenario 'mark mission reviewed' do
      set_mission_state('for_review')
      visit mission_path(mission)

      click_on "Mark 'Reviewed'"
      expect(page).to have_content "Your mission has been approved, you can open for candidates or assign it directly."
    end

    scenario 'assign anyone to a mission', js: true do
      set_mission_state('open_for_candidates')
      visit mission_path(mission)

      click_on 'Applicant(s)'

      within "#pointer_dropdown_box" do
        click_on "Choose a member"
      end

      within ".dropdown-menu" do
        click_on "#{client.first_name} #{client.last_name}"
      end

      # The assigned value is not binded so we have to reload
      visit mission_path(mission)

      expect(page).to have_content "#{client.first_name} #{client.last_name}"
    end
  end

  context 'canditate' do
    before do
      sign_in(canditate)
      set_mission_state('open_for_candidates')
    end

    scenario 'apply on mission that are accepting canditates', js: true do
      visit mission_path(mission)

      find('#interested-label').click

      visit projects_path(state: 'draft')

      expect(page).to have_content '1 applicant(s)'
    end

    scenario "Can't see mission on hold" do
      mission.update(on_hold: true)
      visit missions_path

      expect(page).not_to have_content 'Mission for project The new project title'
    end
  end

  def within_info(&block)
    within('.active div', &block)
  end

  def within_controls(&block)
    within('.header-controls', &block)
  end

  def make_the_canditate_apply
    mission.applicants.create!(state: Applicant.states.unknown, user: canditate)
  end

  def set_mission_state(state)
    mission.update!(state: state)
  end

  def give_mission_to_the_canditate
    mission.update(state: 'assigned', open_for_candidate: true)
    mission.applicants.find_by(user: canditate).update(state: 'assigned')
  end

  def create_invoice(attributes = {})
    line = build(
      :invoice_line,
      description: 'first line',
      rate: 100,
      quantity: 2
    )

    attributes.reverse_merge!(invoice_lines: [line])
    create(:invoice, attributes)
  end
end
