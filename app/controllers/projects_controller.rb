class ProjectsController < ApplicationController
  # regular
  # before_action :check_terms, except: %i[index]

  # during the blitz coaching (should be specific type 'event' ok to show)
  # will not check terms before showing the blitz page
  # before_action :check_terms, except: %i[index], unless: -> { Rails.env.production? and params[:id] == 149 }

  before_action :find_resource, only: %i[show edit update destroy mark_project_reviewed open_project_for_candidates submit_project_for_review hold]
  before_action :create_resource, only: :create
  before_action :authorize_resource, only: %i[create destroy edit show update mark_project_reviewed open_project_for_candidates submit_project_for_review hold]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @body_classes = "bg-light"

    @projects = policy_scope(Project)
    @projects = scope_with_audience(@projects) if params[:audience]
    @projects = @projects.order("#{sort_column} #{sort_direction}")
    per_page = params[:per_page] ||= Project.per_page
    @projects = @projects.paginate(page: params[:page], per_page: per_page)
  end

  def show
    @body_classes = "bg-light"

    @owner = User.friendly.find(@project.user_id)
    @project = Project.where(id: params[:id]).first.decorate
    @project.list_participants
    @project_tag_list = @project.list_tags
    @referal_id = User.find(@owner.id).invited_by_id

    @schedules_data = GoogleSheetsBlitzToCollab.new(selection: ['all']).call if @project.project_type == 'event'
  end

  def new
    @body_classes = "bg-light"

    @project = Project.new
    authorize @project

    @project.user_id = params[:user_id] if params[:user_id]

    3.times { @project.missions.build }
  end

  def edit
    @body_classes = "bg-light"

    @project = Project.includes(:missions).where(id: params[:id]).order('missions.rate DESC').first
    3.times { @project.missions.build } if @project.missions.empty?
  end

  def create
    @body_classes = "bg-light"
    Notifier.call(@project, :creation, audience: Message.audiences.admin) if @project.save
    respond_with @project
  end

  def update
    if @project.update(project_params)
      @project.missions.each(&:submit) if params['submit_for_review']
    end

    respond_with @project
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.js
      format.html { respond_with @project, location: missions_path }
    end
  end

  def hold
    @project.on_hold = !@project.on_hold
    @project.save

    @project.missions.each do |mission|
      mission.on_hold = @project.on_hold
      mission.save
    end

    redirect_to project_path(@project)
  end

  private

  def default_sort_column
    'id'
  end

  def default_sort_order
    'desc'
  end

  def find_resource
    @project = Project.find(params[:id])
  end

  def create_resource
    @project = Project.new(project_params)
  end

  def authorize_resource
    authorize @project
  end

  def private_projects(projects)
    projects.by_user(current_user).or(Project.where(id: Project.assigned_to(current_user)))
  end

  def scope_with_audience(projects)
    case params[:audience]
    when 'private'
      private_projects(projects) if params[:audience] && params[:audience] == 'private'
    when 'public'
      projects.with_open_missions
    else
      projects
    end
  end

  def project_params
    params.require(:project).permit(
      :admin_notes,
      :admin_client,
      :admin_client_summary,
      :admin_references_links,
      :admin_project_type,
      :admin_talents_resources,
      :admin_budget,
      :admin_delivery,
      :admin_position_in_process,
      :admin_extra_info,
      :description,
      :private_notes,
      :title,
      :user_id,
      :project_type,
      :visibility_scope,
      missions_attributes: [
        :id,
        :_destroy,
        :project_id,
        :rate,
        :title,
        :description,
        :position,
        :state,
        :budget_min,
        :budget_max,
        :start_date,
        :end_date
      ]
    )
  end
end
