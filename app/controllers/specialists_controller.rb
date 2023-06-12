class SpecialistsController < ApplicationController
  before_action :set_specialist, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @user = current_user
    @specialists = Specialist.all
    respond_with(@specialists)
  end

  def show
    respond_with(@specialist)
  end

  def new
    @user = current_user
    @specialist = Specialist.new
    respond_with(@specialist)
  end

  def edit
    @user = current_user
  end

  def create
    @specialist = Specialist.new(specialist_params)
    @specialist.user = current_user
    # @specialist.speciality = speciality.where(id: params[:specialities])

    @specialist.save
    redirect_to user_specialists_path
  end

  def update
    @specialist.user = current_user
    @specialist.update(specialist_params)
    redirect_to user_specialists_path
  end

  def destroy
    @specialist.destroy
    respond_with(@specialist)
  end

  private

  def set_specialist
    @specialist = Specialist.find(params[:id])
  end

  def specialist_params
    params.require(:specialist).permit(:active)
  end
end
