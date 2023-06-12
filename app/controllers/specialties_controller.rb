class SpecialtiesController < ApplicationController
  before_action :set_specialty, only: [:show, :edit, :update, :destroy]
  # before_action :specialist_params, only: [:index, :edit, :new, :create, :update]
  before_action :tag_finder, only: [:index, :edit, :update]

  respond_to :html

  include UsersHelper
  include SpecialtiesHelper

  def index
    @body_classes = 'bg-light'
    @user = current_user
    @specialties = @user.specialties

    if @user.employees.present?
      @user.employees.each do |employee|
        user = employee.user
        @specialties += user.specialties unless user.nil?
      end
    elsif @user.has_company.present? && @user.has_company.permission == "admin"
      @employees = @user.has_company.company.employees
      @employees.each do |employee|
        if employee.user_id != @user.id
          user = employee.user
          @specialties += user.specialties unless user.nil?
        end
      end
      @specialties += @user.has_company.company.specialties if @user.has_company.company.specialties.present?
    end
  end

  def show
    respond_with(@specialty)
  end

  def new
    @body_classes = 'bg-light'
    @specialty = Specialty.new
    3.times { @specialty.specialty_lines.build }
    @categories = alphabetic_sort BusinessCategory.all
    @users = company_employees
    @employee = User.find(params[:employee]) if params[:employee].present?
  end

  def edit
    @body_classes = 'bg-light'
    @categories = alphabetic_sort @specialty.business_sub_domain.business_categories
    @users = company_employees
    @employee = params[:employee].present? ? User.find(params[:employee]) : @specialty.user
  end

  def create
    @body_classes = 'bg-light'
    @specialty = Specialty.new(specialty_params)
    @specialty.user_id = current_user.id unless specialty_params[:user_id].present?
    @specialty.business_domain_id = "1"
    @specialty.active = false

    if @specialty.save
      redirect_to specialties_path
    else
      3.times { @specialty.specialty_lines.build }
      @users = company_employees
      if @specialty.business_sub_domain.present?
        @categories = alphabetic_sort @specialty.business_sub_domain.business_categories
      else
        @categories = alphabetic_sort BusinessCategory.all
      end
      
      render :new
    end
  end

  def update
    @specialty.update(specialty_params)

    redirect_to specialties_path
    # redirect_to user_specialist_specialty_path(@specialist.user, @specialist,@specialty)
  end

  def destroy
    @specialty.destroy
    redirect_to specialties_path
  end

  def filter_specialties
    @sub_domain_id = params[:sub_domain_id]
    @categories = BusinessCategory.where(business_sub_domain_id: @sub_domain_id)
    @categories = alphabetic_sort @categories

    respond_to do |format|
      format.html {render @categories}
      format.js 
    end
  end

  def update_active
    status = params[:active]
    id = params[:id]
    Specialty.find(id).update(active: status.to_bool)
  end

  private

  def tag_finder
    @sector_tags = ActsAsTaggableOn::Tag.where(role: "sector")
  end

  def set_specialty
    @specialty = Specialty.find(params[:id])
  end

  def specialty_params
    params.require(:specialty).permit(
      :user_id,
      :business_domain_id,
      :business_sub_domain_id,
      :business_category_id,
      :active,
      :title,
      :experience,
      :sector_id,
      :software_list,
      specialty_lines_attributes: [
        :id,
        :_destroy,
        :experience,
        :specialty_id,
        :sector_id
      ]
    )
  end
end