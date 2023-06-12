require "application_system_test_case"

class SectorsTest < ApplicationSystemTestCase
  setup do
    @sector = sectors(:one)
  end

  test "visiting the index" do
    visit sectors_url
    assert_selector "h1", text: "Sectors"
  end

  test "creating a Sector" do
    visit sectors_url
    click_on "New Sector"

    fill_in "Abr", with: @sector.abr
    fill_in "Name", with: @sector.name
    click_on "Create Sector"

    assert_text "Sector was successfully created"
    click_on "Back"
  end

  test "updating a Sector" do
    visit sectors_url
    click_on "Edit", match: :first

    fill_in "Abr", with: @sector.abr
    fill_in "Name", with: @sector.name
    click_on "Update Sector"

    assert_text "Sector was successfully updated"
    click_on "Back"
  end

  test "destroying a Sector" do
    visit sectors_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Sector was successfully destroyed"
  end
end
