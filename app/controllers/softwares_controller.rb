class SoftwaresController < ApplicationController
  before_action :set_software, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @softwares = Software.all
    respond_with(@softwares)
  end

  def show
    respond_with(@software)
  end

  def new
    @software = Software.new
    respond_with(@software)
  end

  def edit
  end

  def create
    @software = Software.new(software_params)
    @software.save
    respond_with(@software)
  end

  def update
    @software.update(software_params)
    respond_with(@software)
  end

  def destroy
    @software.destroy
    respond_with(@software)
  end

  private

  def set_software
    @software = Software.find(params[:id])
  end

  def software_params
    params.require(:software).permit(:name, :abr, :number)
  end
end
