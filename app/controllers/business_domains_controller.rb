class BusinessDomainsController < ApplicationController
  before_action :set_business_domain, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @business_domains = BusinessDomain.all
    respond_with(@business_domains)
  end

  def show
    respond_with(@business_domain)
  end

  def new
    @business_domain = BusinessDomain.new
    respond_with(@business_domain)
  end

  def edit
  end

  def create
    @business_domain = BusinessDomain.new(business_domain_params)
    @business_domain.save
    respond_with(@business_domain)
  end

  def update
    @business_domain.update(business_domain_params)
    respond_with(@business_domain)
  end

  def destroy
    @business_domain.destroy
    respond_with(@business_domain)
  end

  private

  def set_business_domain
    @business_domain = BusinessDomain.find(params[:id])
  end

  def business_domain_params
    params.require(:business_domain).permit(*Utils::Locales.translated_param_names(:name))
  end
end
