require "application_system_test_case"

class SpecialitiesTest < ApplicationSystemTestCase
  setup do
    @speciality = specialities(:one)
  end

  test "visiting the index" do
    visit specialities_url
    assert_selector "h1", text: "Specialities"
  end

  test "creating a Speciality" do
    visit specialities_url
    click_on "New Speciality"

    fill_in "Active", with: @speciality.active
    fill_in "Business categories", with: @speciality.business_categories_id
    fill_in "Experience", with: @speciality.experience
    fill_in "Skill", with: @speciality.skill
    fill_in "Specialists", with: @speciality.specialists_id
    click_on "Create Speciality"

    assert_text "Speciality was successfully created"
    click_on "Back"
  end

  test "updating a Speciality" do
    visit specialities_url
    click_on "Edit", match: :first

    fill_in "Active", with: @speciality.active
    fill_in "Business categories", with: @speciality.business_categories_id
    fill_in "Experience", with: @speciality.experience
    fill_in "Skill", with: @speciality.skill
    fill_in "Specialists", with: @speciality.specialists_id
    click_on "Update Speciality"

    assert_text "Speciality was successfully updated"
    click_on "Back"
  end

  test "destroying a Speciality" do
    visit specialities_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Speciality was successfully destroyed"
  end
end
