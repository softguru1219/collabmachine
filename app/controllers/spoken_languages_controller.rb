class SpokenLanguagesController < ApplicationController
  before_action :set_spoken_language, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @Spokens = Speciality.all
    respond_with(@Spokens)
  end

  def show
    respond_with(@spoken_language)
  end

  def new
    @spoken_language = SpokenLanguage.new
    respond_with(@spoken_language)
  end

  def edit
  end

  def create
    @spoken_language = SpokenLanguage.new(poken_language_params)
    @spoken_language.save
    respond_with(@spoken_language)
  end

  def update
    @spoken_language.update(spoken_language_params)
    respond_with(@spoken_language)
  end

  def destroy
    @spoken_language.destroy
    respond_with(@spoken_language)
  end

  private

  def set_spoken_language
    @spoken_language = SpokenLanguage.find(params[:id])
  end

  def spoken_params
    params.require(:spoken_languages).permit(:language, :abr, :level, :user_id)
  end
end
