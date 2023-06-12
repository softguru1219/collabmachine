require "application_system_test_case"

class SpecialistsTest < ApplicationSystemTestCase
  setup do
    @specialist = specialists(:one)
  end

  test "visiting the index" do
    visit specialists_url
    assert_selector "h1", text: "Specialists"
  end

  test "creating a Specialist" do
    visit specialists_url
    click_on "New Specialist"

    check "Active" if @specialist.active
    check "English" if @specialist.english
    fill_in "First name", with: @specialist.first_name
    check "French" if @specialist.french
    fill_in "Last name", with: @specialist.last_name
    fill_in "Linkedin", with: @specialist.linkedin
    fill_in "Others languages", with: @specialist.others_languages
    fill_in "Pseudo", with: @specialist.pseudo
    fill_in "Sector", with: @specialist.sector
    fill_in "Software", with: @specialist.software
    fill_in "User", with: @specialist.user_id
    click_on "Create Specialist"

    assert_text "Specialist was successfully created"
    click_on "Back"
  end

  test "updating a Specialist" do
    visit specialists_url
    click_on "Edit", match: :first

    check "Active" if @specialist.active
    check "English" if @specialist.english
    fill_in "First name", with: @specialist.first_name
    check "French" if @specialist.french
    fill_in "Last name", with: @specialist.last_name
    fill_in "Linkedin", with: @specialist.linkedin
    fill_in "Others languages", with: @specialist.others_languages
    fill_in "Pseudo", with: @specialist.pseudo
    fill_in "Sector", with: @specialist.sector
    fill_in "Software", with: @specialist.software
    fill_in "User", with: @specialist.user_id
    click_on "Update Specialist"

    assert_text "Specialist was successfully updated"
    click_on "Back"
  end

  test "destroying a Specialist" do
    visit specialists_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Specialist was successfully destroyed"
  end
end
