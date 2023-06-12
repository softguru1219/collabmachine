class BusinessCategoriesController < ApplicationController
  before_action :set_business_category, only: [:show, :edit, :update, :destroy]
  before_action :business_sub_domain_params, only: [:index, :edit, :new, :create]

  respond_to :html

  def index
    @business_categories = BusinessCategory.all
    respond_with(@business_categories)
  end

  def show
    respond_with(@business_category)
  end

  def new
    @business_category = BusinessCategory.new
    respond_with(@business_category)
  end

  def edit
  end

  def create
    @business_category = BusinessCategory.new(business_category_params)
    @business_category.business_sub_domain = BusinessSubDomain.find(params[:business_sub_domain_id])
    @business_category.save
    respond_with(@business_category)
  end

  def update
    @business_category.business_sub_domain = BusinessSubDomain.find(params[:business_sub_domain_id])
    @business_category.update(business_category_params)
    respond_with(@business_category)
  end

  def destroy
    @business_category.destroy
    respond_with(@business_category)
  end

  private


  def business_sub_domain_params
    @business_sub_domain = BusinessSubDomain.find(params[:business_sub_domain_id])
  end

  def set_business_category
    @business_category = BusinessCategory.find(params[:id])
  end

  def business_category_params

    params.require(:business_category).permit(
      *Utils::Locales.translated_param_names(
        :abr,
        :name,
        :display
      )
    )

  end
end
