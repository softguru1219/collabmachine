class BusinessSubDomainsController < ApplicationController
  before_action :set_business_sub_domain, only: [:show, :edit, :update, :destroy]
  before_action :business_domain_params, only: [:index, :edit, :new, :create]

  respond_to :html

  def index
    @business_sub_domains = BusinessSubDomain.all
    respond_with(@business_sub_domains)
  end

  def show
    respond_with(@business_sub_domain)
  end

  def new
    @business_sub_domain = BusinessSubDomain.new
  end

  def edit
  end

  def create
    @business_sub_domain = BusinessSubDomain.new(business_sub_domain_params)
    @business_sub_domain.business_domain = @business_domain
    @business_sub_domain.save
    if @business_sub_domain.save
      redirect_to business_domain_path(@business_domain)
    else
      render :new
    end
  end

  def update
    @business_sub_domain.business_domain = BusinessDomain.where(id: params[:business_domain_id])
    @business_sub_domain.update(business_sub_domain_params)
    respond_with(@business_sub_domain)
  end

  def destroy
    @business_sub_domain.destroy
    respond_with(@business_sub_domain)
  end

  private

  def business_domain_params
    @business_domain = BusinessDomain.find(params[:business_domain_id])
  end

  def set_business_sub_domain
    @business_sub_domain = BusinessSubDomain.find(params[:id])
  end

  def business_sub_domain_params
    params.require(:business_sub_domain).permit(
      *Utils::Locales.translated_param_names(
        :name,
        :display
      )
    )
  end
end
