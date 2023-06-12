class PagesController < ApplicationController
  before_action :find_resource, only: %i[show edit update destroy]
  before_action :new_resource, only: :new

  def index
    @pages = Page.all
  end

  def show
    puts @page.inspect
  end

  def new; end

  def create
    @page = Page.new(page_params)
    if @page.save
      redirect_to @page, success: 'Page is successfully created'
    else
      render :new, error: "Error while creating new page"
    end
  end

  def edit; end

  def update
    @page.update(page_params)
    if @page.save
      redirect_to page_path(@page), success: 'Page is successfully updated'
    else
      render :edit, error: "Error while updating new page"
    end
  end

  def destroy
    @page.destroy
    redirect_to pages_path, success: 'Page is successfully deleted'
  end

  def show_by_slug
    Page.all if params[:slug] == 'dashblog'
    params[:slug] = 'home'

    render :show
  end

  private

  def find_resource
    @page = Page.friendly.find(params[:id])
  end

  def new_resource
    @page = Page.new
  end

  def create_resource
    @page = Page.new(page_params)
  end

  def page_params
    params.require(:page).permit(
      :title,
      :slug,
      :path,
      :content,
      :language,
      :hide_title,
      :hide_body
    )
  end
end
