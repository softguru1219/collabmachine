class MissionsController < ApplicationController
  before_action :check_terms, except: %i[index show]

  before_action :find_resource, only: %i[show edit update destroy mark_mission_reviewed open_mission_for_candidates submit_mission_for_review start finish reopen archive hold slack_notify_new_mission]
  before_action :authorize_resource, only: %i[destroy edit show update mark_mission_reviewed open_mission_for_candidates submit_mission_for_review start finish reopen archive hold slack_notify_new_mission]
  after_action :verify_authorized, except: %i[index sort]

  def index
    # @body_classes = "bg-light"

    @per_page = params[:per_page] ||= Mission.per_page

    @filterrific = initialize_filterrific(
      Mission,
      params[:filterrific],
      sanitize_params: true,
      persistence_id: 'shared_key'
    ) or return

    @opportunities = @filterrific.find.page(params[:page])
    @opportunities = @opportunities.where(state: 'open_for_candidates').includes(:applicants, :project, :user)

    @my_missions = Mission.by_user(current_user).includes(:applicants, :project)

    @assigned = Mission.includes(:applicants, :project).where(applicants: { user: current_user })
    @assigned = @assigned.where(state: 'open_for_candidates').or(@assigned.assigned_to(current_user))

    @suggested_on_draft = Applicant.where(user_id: current_user.id, state: 'suggested')

    @new_missions = []
    @suggested_on_draft.each do |applicant|
      mission_found = Mission.find(applicant.mission_id)
      state_found = mission_found.state
      @new_missions << mission_found if ['draft', 'for_review', 'reviewed'].include?(state_found)
    end
  end

  def show
    @body_classes = "bg-light"

    @mission = Mission.includes(:applicants).where(id: params[:id]).order('applicants.state ASC').first.decorate
    @messages = @mission.messages.public_or_private

    @assignments = Applicant.where(mission_id: @mission.id, state: "assigned")
    @im_interested = Applicant.where(mission_id: @mission.id, user_id: current_user.id).any?
    @suggested = Applicant.where(mission_id: @mission.id, user_id: current_user.id, state: 'suggested').any?
    @referal_id = User.find(@mission.project_user_id).invited_by_id

    sanitized_description = ActionController::Base.helpers.sanitize(
      @mission.description.mb_chars.limit(400).to_s
    )

    prepare_meta_tags(
      title: @mission.title,
      description: "#{sanitized_description}..."
    )
  end

  def update
    @mission.update(mission_params)
    respond_with @mission
  end

  def destroy
    @mission.destroy
    respond_to do |format|
      format.js
      format.html { respond_with @mission, location: -> { project_path(@mission.project) } }
    end
  end

  def contact_params
    params.require(:contact).permit(:mission_id, :email)
  end

  # async ... maybe later?
  def mark_mission_reviewed
    @mission.review
    redirect_to mission_path(@mission)
  end

  # async ... maybe later
  def open_mission_for_candidates
    @mission.invite_candidates
    redirect_to mission_path(@mission)
  end

  # async ...
  def submit_mission_for_review
    @mission.submit
    NotifyAdminReviewJob.perform_later(@mission)
    redirect_to mission_path(@mission)
  end

  def start
    @mission.start
    redirect_to mission_path(@mission)
  end

  def finish
    @mission.finish
    redirect_to mission_path(@mission)
  end

  def reopen
    @mission.reopen
    redirect_to mission_path(@mission)
  end

  def archive
    @mission.archive
    redirect_to mission_path(@mission)
  end

  def hold
    @mission.on_hold = !@mission.on_hold
    @mission.save
    redirect_to mission_path(@mission)
  end

  def sort
    params[:mission].each_with_index do |id, index|
      Mission.find(id).update_attribute('position', index + 1)
    end
    head :ok
  end

  def slack_notify_new_mission
    client = Slack::Web::Client.new
    client.auth_test
    client.chat_postMessage(
      channel: '#jobs',
      # as_user: true,
      username: "CollabMachine - Nouvelle mission!",
      text: "Nouvelle opportunité <!channel> <!here>", # <> are used for linking
      icon_emoji: ":collision:",
      attachments: [ # attachments, here we also use long attachment to use more space
        {
          color: "#333333",
          fields: [
            {
              title: "Mission:",
              value: @mission.title,
              short: false
            },
            {
              title: "Description",
              value: @mission.description.strip_tags.truncate(300),
              short: false # marks this to be wide attachment
            },
            # {
            #   title: "ID du projet",
            #   value: "2657",
            #   short: true
            # },
            # {
            #   title: "Collab Machine",
            #   value: "Merci d'être la !",
            #   short: true
            # },
          ],
          actions: [ # Slack supports many kind of different types, we'll use buttons here
            {
              type: "button",
              text: "En savoir plus", # text on the button
              style: "primary",
              url: url_for(controller: 'missions', action: :show, id: @mission.id, locale: 'fr') # url the button will take the user if clicked
            }
            # ,
            # {
            #   type: "button",
            #   text: "Consulter la liste", # text on the button
            #   style: "success",
            #   url: "https://collabmachine.com/missions" # url the button will take the user if clicked
            # },
            # {
            #   type: "button",
            #   text: "Profile",
            #   style: "danger",
            #   url: "https://collabmachine.com/fr/users/sign_up" # TODO: développer route collabmachine.com/me = user logged in
            # }
          ]
        }
      ]
    )
  end

  private

  def default_sort_column
    'id'
  end

  def default_sort_order
    'desc'
  end

  def find_resource
    @mission = Mission.find(params[:id])
  end

  def authorize_resource
    authorize @mission
  end

  def mission_params
    params.require(:mission).permit(
      :admin_notes,
      :description,
      :position,
      :tag_list,
      :project_id,
      :rate,
      :state,
      :terms,
      :title,
      :user_id,
      :start_date,
      :end_date,
      :budget_min,
      :budget_max
    )
  end

  def private_missions(missions)
    missions.by_user(current_user).or(id: Mission.assigned_to(current_user))
  end

  def scope_with_audience(missions)
    case params[:audience]
    when 'private'
      private_missions(missions) if params[:audience] && params[:audience] == 'private'
    when 'public'
      missions.where(state: 'open_for_candidates')
    else
      missions.by_user(current_user).or(id: Mission.assigned_to(current_user)).or(state: 'open_for_candidates')
    end
  end
end
