require "application_system_test_case"

class BusinessCategoriesTest < ApplicationSystemTestCase
  setup do
    @business_category = business_categories(:one)
  end

  test "visiting the index" do
    visit business_categories_url
    assert_selector "h1", text: "Business Categories"
  end

  test "creating a Business category" do
    visit business_categories_url
    click_on "New Business Category"

    fill_in "Abr en", with: @business_category.abr_en
    fill_in "Abr fr", with: @business_category.abr_fr
    fill_in "Business sub domain", with: @business_category.business_sub_domain_id
    check "Display en" if @business_category.display_en
    check "Display fr" if @business_category.display_fr
    fill_in "Name en", with: @business_category.name_en
    fill_in "Name fr", with: @business_category.name_fr
    click_on "Create Business category"

    assert_text "Business category was successfully created"
    click_on "Back"
  end

  test "updating a Business category" do
    visit business_categories_url
    click_on "Edit", match: :first

    fill_in "Abr en", with: @business_category.abr_en
    fill_in "Abr fr", with: @business_category.abr_fr
    fill_in "Business sub domain", with: @business_category.business_sub_domain_id
    check "Display en" if @business_category.display_en
    check "Display fr" if @business_category.display_fr
    fill_in "Name en", with: @business_category.name_en
    fill_in "Name fr", with: @business_category.name_fr
    click_on "Update Business category"

    assert_text "Business category was successfully updated"
    click_on "Back"
  end

  test "destroying a Business category" do
    visit business_categories_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Business category was successfully destroyed"
  end
end
