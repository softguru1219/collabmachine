require "test_helper"

class BusinessSubDomainsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @business_sub_domain = business_sub_domains(:one)
  end

  test "should get index" do
    get business_sub_domains_url
    assert_response :success
  end

  test "should get new" do
    get new_business_sub_domain_url
    assert_response :success
  end

  test "should create business_sub_domain" do
    assert_difference('BusinessSubDomain.count') do
      post business_sub_domains_url, params: { business_sub_domain: { business_domain_id: @business_sub_domain.business_domain_id, display_en: @business_sub_domain.display_en, display_fr: @business_sub_domain.display_fr, name_en: @business_sub_domain.name_en, name_fr: @business_sub_domain.name_fr } }
    end

    assert_redirected_to business_sub_domain_url(BusinessSubDomain.last)
  end

  test "should show business_sub_domain" do
    get business_sub_domain_url(@business_sub_domain)
    assert_response :success
  end

  test "should get edit" do
    get edit_business_sub_domain_url(@business_sub_domain)
    assert_response :success
  end

  test "should update business_sub_domain" do
    patch business_sub_domain_url(@business_sub_domain), params: { business_sub_domain: { business_domain_id: @business_sub_domain.business_domain_id, display_en: @business_sub_domain.display_en, display_fr: @business_sub_domain.display_fr, name_en: @business_sub_domain.name_en, name_fr: @business_sub_domain.name_fr } }
    assert_redirected_to business_sub_domain_url(@business_sub_domain)
  end

  test "should destroy business_sub_domain" do
    assert_difference('BusinessSubDomain.count', -1) do
      delete business_sub_domain_url(@business_sub_domain)
    end

    assert_redirected_to business_sub_domains_url
  end
end
