class SpecialitiesController < ApplicationController
  before_action :set_speciality, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @specialities = Speciality.all
    respond_with(@specialities)
  end

  def show
    respond_with(@speciality)
  end

  def new
    @speciality = Speciality.new
    respond_with(@speciality)
  end

  def edit
  end

  def create
    @speciality = Speciality.new(speciality_params)
    @speciality.save
    respond_with(@speciality)
  end

  def update
    @speciality.update(speciality_params)
    respond_with(@speciality)
  end

  def destroy
    @speciality.destroy
    respond_with(@speciality)
  end

  private

  def set_speciality
    @speciality = Speciality.find(params[:id])
  end

  def speciality_params
    params.require(:speciality).permit(:active, :experience, :skill, :specialists_id, :business_categories_id)
  end
end
