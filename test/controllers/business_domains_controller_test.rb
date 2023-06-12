require "test_helper"

class BusinessDomainsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @business_domain = business_domains(:one)
  end

  test "should get index" do
    get business_domains_url
    assert_response :success
  end

  test "should get new" do
    get new_business_domain_url
    assert_response :success
  end

  test "should create business_domain" do
    assert_difference('BusinessDomain.count') do
      post business_domains_url, params: { business_domain: { name_en: @business_domain.name_en, name_fr: @business_domain.name_fr } }
    end

    assert_redirected_to business_domain_url(BusinessDomain.last)
  end

  test "should show business_domain" do
    get business_domain_url(@business_domain)
    assert_response :success
  end

  test "should get edit" do
    get edit_business_domain_url(@business_domain)
    assert_response :success
  end

  test "should update business_domain" do
    patch business_domain_url(@business_domain), params: { business_domain: { name_en: @business_domain.name_en, name_fr: @business_domain.name_fr } }
    assert_redirected_to business_domain_url(@business_domain)
  end

  test "should destroy business_domain" do
    assert_difference('BusinessDomain.count', -1) do
      delete business_domain_url(@business_domain)
    end

    assert_redirected_to business_domains_url
  end
end
