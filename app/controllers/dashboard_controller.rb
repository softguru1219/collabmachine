class DashboardController < ApplicationController
  before_action :authorize_resource, only: %i[missions users metrics slack_users trousse_participant_automne_2021]
  after_action :verify_authorized, only: %i[missions users metrics slack_users trousse_participant_automne_2021]

  def index
    @body_classes = "bg-light"
    items_per_box = 10

    @referrals = User.where(invited_by: current_user.id).order(active: :asc, invitation_sent_at: :desc, invitation_accepted_at: :desc).limit(items_per_box)
    @referrals_has_more = @referrals.count > items_per_box ? true : nil

    @by_me = Project.by_user(current_user).limit(items_per_box).includes(:missions)
    @by_me_has_more = @by_me.count > items_per_box ? true : nil

    @to_me = Project.assigned_to(current_user).includes(:missions)
    @to_me = @to_me.order("created_at DESC").limit(items_per_box)
    @to_me_has_more = Project.assigned_to(current_user).count > items_per_box ? true : nil

    @suggested_to_me = Applicant.includes(:mission).where(user_id: current_user.id, state: "suggested", 'missions.state': 'open_for_candidates').pluck(:title, :mission_id, :created_at)

    opportunities_all = Project.with_open_missions
    @opportunities = opportunities_all.order("projects.created_at DESC").limit(items_per_box).includes(:missions)
    @opportunities_has_more = opportunities_all.count > items_per_box ? true : nil
  end

  def metrics
    @projects = Project.all
  end

  def slack_users
    client = Slack::Web::Client.new
    @slack_users = [] # many thousands of team members retrieved 10 at a time
    client.users_list(presence: true, limit: 10) do |response|
      @slack_users.concat(response.members)
    end
  end

  def missions
    @body_classes = 'page-wide'
    @missions = Mission.all.includes([:project, :applicants])
  end

  def users
    @users = policy_scope(User)

    @filterrific = initialize_filterrific(
      User,
      params[:filterrific],
      persistence_id: 'shared_key',
      sanitize_params: true
    ) or return

    @users = @filterrific.find.page(params[:page])
    @users = @users.order(rating: :desc).includes(:taggings)
  end

  def participation_system; end

  def master_service_agreement; end

  def get_contract_data
    if params[:partA_id] && params[:partB_id]
      @service_provider = User.find(params[:partA_id])
      @customer = User.find(params[:partB_id])
      @base_vars = {
        contract_date: Date.today,
        service_provider_identity: @service_provider.company,
        service_provider_address: @service_provider.location,
        service_provider_address_for_notice: @service_provider.location,
        service_provider_attention_to: @service_provider.full_name,
        service_provider_email: @service_provider.email,
        service_provider_responsible_name: @service_provider.full_name,
        service_provider_responsible_title: @service_provider.headline,
        service_provider_manager_name: @service_provider.full_name,
        service_provider_manager_email: @service_provider.email,
        service_provider_manager_phone: @service_provider.phone,
        customer_identity: @customer.company || "Customer Identity??",
        customer_address: @customer.location,
        customer_address_for_notice: @customer.location,
        customer_attention_to: @customer.full_name,
        customer_email: @customer.email,
        customer_responsible_name: @customer.full_name,
        customer_responsible_title: @customer.headline,
        customer_manager_name: @customer.full_name,
        customer_manager_email: @customer.email,
        customer_manager_phone: @customer.phone
      }
    else
      "empty!!!!"
    end
  end

  def participants
    @schedules_data = GoogleSheetsBlitzToCollab.new(selection: ['all']).call
  end

  def coachs
    @schedules_data = GoogleSheetsBlitzToCollab.new(selection: ['all']).call
  end

  def meeting_participants
    @schedules_data = GoogleSheetsBlitzToCollab.new(selection: ['all']).call
  end

  def meet
    @body_classes = 'page-wide'
    @room = params[:room]
    @schedules_data = GoogleSheetsBlitzToCollab.new(selection: ['all']).call

    target_user_id = nil

    cols = @schedules_data[:coachs][:col_names]
    @schedules_data[:coachs][:rows].values.each do |coach|
      next if coach[cols[:PROCESS]] == "FALSE"
      next if coach[cols[:'Salle jitsi']].nil?
      next unless request.url.include?(coach[cols[:'Salle jitsi']])

      target_user_id = User.find_by_email(coach[cols[:Email]])&.id
    end

    Tracker.create!(
      user_id: current_user.id,
      target: request.url,
      target_user_id: target_user_id
    )
  end

  def blitz_logs
    @body_classes = 'page-wide'
    @rooms = Tracker.group(:target, :id)

    from = params[:from] or nil
    to = params[:to] or nil

    @log_entries =
      if from && to
        Tracker.from_to(from, to).order(target: :asc, created_at: :desc)
      elsif from
        Tracker.from_to(from, "23:59").order(target: :asc, created_at: :desc)
      else
        Tracker.order(target: :asc, created_at: :desc)
      end
  end

  def blitz_followup
    @body_classes = 'page-wide'
    @schedules_data = GoogleSheetsBlitzToCollab.new(selection: ['all']).call

    # @rooms = Tracker.group(:target)

    @from = params[:from] or redirect_to blitz_followup_path(from: '9h15')

    @to = params[:to] or nil

    @log_entries =
      if @from && @to
        Tracker.from_to(@from, @to).order(target: :asc, created_at: :desc)
      elsif @from
        Tracker.from_to(@from, "23:59").order(target: :asc, created_at: :desc)
      else
        Tracker.order(target: :asc, created_at: :desc)
      end
  end

  def trousse_participant_automne_2021
  end

  private

  def authorize_resource
    authorize current_user
  end
end
