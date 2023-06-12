require "application_system_test_case"

class BusinessDomainsTest < ApplicationSystemTestCase
  setup do
    @business_domain = business_domains(:one)
  end

  test "visiting the index" do
    visit business_domains_url
    assert_selector "h1", text: "Business Domains"
  end

  test "creating a Business domain" do
    visit business_domains_url
    click_on "New Business Domain"

    fill_in "Name en", with: @business_domain.name_en
    fill_in "Name fr", with: @business_domain.name_fr
    click_on "Create Business domain"

    assert_text "Business domain was successfully created"
    click_on "Back"
  end

  test "updating a Business domain" do
    visit business_domains_url
    click_on "Edit", match: :first

    fill_in "Name en", with: @business_domain.name_en
    fill_in "Name fr", with: @business_domain.name_fr
    click_on "Update Business domain"

    assert_text "Business domain was successfully updated"
    click_on "Back"
  end

  test "destroying a Business domain" do
    visit business_domains_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Business domain was successfully destroyed"
  end
end
