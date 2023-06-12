require "application_system_test_case"

class BusinessSubDomainsTest < ApplicationSystemTestCase
  setup do
    @business_sub_domain = business_sub_domains(:one)
  end

  test "visiting the index" do
    visit business_sub_domains_url
    assert_selector "h1", text: "Business Sub Domains"
  end

  test "creating a Business sub domain" do
    visit business_sub_domains_url
    click_on "New Business Sub Domain"

    fill_in "Business domain", with: @business_sub_domain.business_domain_id
    check "Display en" if @business_sub_domain.display_en
    check "Display fr" if @business_sub_domain.display_fr
    fill_in "Name en", with: @business_sub_domain.name_en
    fill_in "Name fr", with: @business_sub_domain.name_fr
    click_on "Create Business sub domain"

    assert_text "Business sub domain was successfully created"
    click_on "Back"
  end

  test "updating a Business sub domain" do
    visit business_sub_domains_url
    click_on "Edit", match: :first

    fill_in "Business domain", with: @business_sub_domain.business_domain_id
    check "Display en" if @business_sub_domain.display_en
    check "Display fr" if @business_sub_domain.display_fr
    fill_in "Name en", with: @business_sub_domain.name_en
    fill_in "Name fr", with: @business_sub_domain.name_fr
    click_on "Update Business sub domain"

    assert_text "Business sub domain was successfully updated"
    click_on "Back"
  end

  test "destroying a Business sub domain" do
    visit business_sub_domains_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Business sub domain was successfully destroyed"
  end
end
