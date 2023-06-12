class UsersController < ApplicationController
  include BlitzHelper
  before_action :local_check_terms, only:  %i[create edit destroy]
  before_action :find_resource, only:      %i[destroy edit show update update_payment_information resend_invitation set_participation_next_blitz]
  skip_before_action :authenticate_user!, only: [:show]
  before_action :authorize_resource, only: %i[destroy edit update update_payment_information resend_invitation]
  after_action :verify_authorized, except: %i[index employees show payment_information update_payment_information accept_terms accept_terms_for_current_user resend_invitation send_onboarding_message reset_card set_participation_next_blitz create_employee]

  before_action :verify_employees, only: %i[employees]

  include UsersHelper

  def index
    authorize User

    @filterrific = initialize_filterrific(
      User,
      params[:filterrific],
      persistence_id: 'shared_key',
      sanitize_params: true,
      default_filter_params: { sorted_by: "availability_desc" }
    ) || return

    @users = @filterrific
      .find
      .paginate(page: params[:page], per_page: 25)
      .includes(:skills, :interests, :admin_tags)
      .with_attached_avatar
      .order(rating: :desc)

    @body_classes = 'page-wide' if params[:layout] == 'list_admin'

    @users = @users.where(active: true) unless current_user.admin?
  end

  def employees
    @users = company_employees
    @users = @users.present? ? @users.order(:first_name) : []
  end

  def create_employee
    first_name = params[:first_name]
    last_name = params[:last_name]
    email = Faker::Internet.email
    password=('0'..'z').to_a.shuffle.first(10).join

    @user = User.new
    @user.email = email
    @user.password = password
    @user.password_confirmation = password
    @user.first_name = params[:first_name]
    @user.last_name = params[:last_name]

    if @user.save
      if current_user.employees.present?
        companyId = current_user.id
      else
        companyId = current_user.has_company.company_id
      end
      UsersCompany.create(company_id: companyId, user_id: @user.id)
    end

    params[:current_path] = params[:current_path] + "/?employee=#{@user.id}" if params[:current_path].include?("specialties")
    
    redirect_to params[:current_path]

  end

  def admin_index
    authorize User

    @body_classes = 'page-wide'

    @filterrific = initialize_filterrific(
      User,
      params[:filterrific],
      persistence_id: 'shared_key',
      sanitize_params: true
    ) || return

    @users = @filterrific
      .find
      .paginate(page: params[:page], per_page: 25)
      .includes(:skills, :interests, :admin_tags, :slack_username_attribute)
      .with_attached_avatar
  end

  def edit
    @body_classes = "bg-light"
  end

  def update
    @user.update(user_params)
    3.times { @user.spoken_languages.build }
    respond_with @user
  end

  def update_payment_information
    if params[:stripe_temporary_token] && update_stripe_customer
      render json: @user
    else
      render json: {}, status: :unprocessable_enitity
    end
  end

  def show
    @body_classes = "bg-light"

    UserRules.new.can_activate_account(current_user) if user_signed_in?
    @messages = policy_scope(Message).where("recipient = :user_id", user_id: @user.id).order(updated_at: 'desc') if user_signed_in?
    @projects = Project.where(user_id: @user.id)
    @taxes = @user.taxes
    @tax = Tax.new
    @infos = @user.financial_infos
    @info = FinancialInfo.new

    # #######################################################################
    # todo: Needs to be improved (not efficient)
    # should load missions through applicants association instead of
    # looping to collect them all
    @pipeline_missions = []
    Applicant.includes([:mission]).where(user_id: @user.id, state: 'assigned').each do |applicant|
      # @pipeline_missions.push(Mission.find(applicant.mission_id))
      @pipeline_missions.push(applicant.mission)
    end
    # #######################################################################

    @superadmin_data = {
      missions_for_review: Mission.with_state(:for_review),
      progress: {
        firstname: @user.first_name,
        email: @user.email,
        profile: @user.meta_attributes.where(name: 'cm__platform__profile_quality').first&.value || 0,
        slack: @user.meta_attributes.where(name: 'cm__slack__userid').first&.value&.empty? ? 0 : 1,
        newsletter: @user.meta_attributes.where(name: 'cm__newsletter__subscribed').first&.value || 0,
        linkedin_page: 0,
        linkedin_group: @user.meta_attributes.where(name: 'cm__linkedin__group').first&.value || 0,
        facebook_page: @user.meta_attributes.where(name: 'cm__facebook__page').first&.value&.empty? ? 0 : 1,
        general_info: 1
      }.to_json
    }
    @products = @user.products.published.includes(:categories)
    @selected_product = @products.first
    @user_level = current_user&.access_level || nil if current_user.present?
    @projects_number = current_user&.projects&.count || nil if current_user.present?
    @missions_number = current_user&.missions&.count || nil if current_user.present?
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  def accept_terms_for_current_user
    if user_params[:terms_accepted_at] == 'true'
      current_user.terms_accepted_at = user_params[:terms_accepted_at].to_bool
      if current_user.save
        url = params[:user][:then] || dashboard_path
        redirect_to url
      else
        render :accept_terms
      end
    end
  end

  def accept_terms
    @then = params[:then]
    @body_classes = "bg-light full min850"
  end

  def resend_invitation
    user_to_invite = User.where(email: @user.email).first
    user_to_invite.invited_handle = user_to_invite.first_name
    user_to_invite.deliver_invitation
    # token = user_to_invite.raw_invitation_token
    redirect_to @user, notice: "Invitation re-sent to #{user_to_invite.email}."
  end

  def fetch_user_data
    authorize User
    GoogleSheetsToCollab.new(selection: [params[:email]]).call
  end

  def fetch_all_users_data
    authorize User
    GoogleSheetsToCollab.new(selection: ['all']).call
  end

  def import_coachs
    authorize User
    response = GoogleSheetsBlitzToCollab.new(selection: ['all']).import_coachs
    @msg = response[:messages]
  end

  def import_participants
    authorize User
    response = GoogleSheetsBlitzToCollab.new(selection: ['all']).import_participants
    @msg = response[:messages]
  end

  def export_participants
    authorize User
    GoogleSheetsBlitzToCollab.new(selection: ['all']).export_participants
  end

  def export_coachs
    authorize User
    GoogleSheetsBlitzToCollab.new(selection: ['all']).export_coachs
  end

  # db to google sheet
  def fetch_blitz_users
    authorize User
    response = GoogleSheetsBlitzToCollab.new(selection: ['all']).import_coachs
    @msg = response[:messages]
  end

  def set_participation_next_blitz
    @user.blitz_roles = params[:blitz_roles]

    if @user.blitz_roles.include?('coach') or @user.blitz_roles.include?('entrepreneur')
      @user.admin_tag_list.add(next_blitz_tag) unless @user.in_next_blitz?
    else
      @user.admin_tag_list.remove(next_blitz_tag)
    end

    @user.save
    is_participant = @user.in_next_blitz?

    render json: {
      is_participant: is_participant,
      button_caption: is_participant ? I18n.t('users.show.toggle_blitz_button_caption_is_participant') : I18n.t('users.show.toggle_blitz_button_caption_not_participant'),
      status: 'OK'
    }
  end

  def send_onboarding_message
    params[:sender] = 'support@collabmachine.com'
    MessageMailer.send_onboarding_message(params).deliver_now

    # TODO: should catch if it worked or not.
    render json: { status: 'OK' }
  end

  def reset_card
    Stripe::Customer.delete_source(
      current_user.stripe_customer.id,
      current_user.stripe_customer.sources.data[0].id
    )
    redirect_to invoice_path(id: params[:invoice_id])
  end

  private

  def local_check_terms
    find_resource
    check_terms and return if current_user.id != @user.id
  end

  def flash_interpolation_options
    { resource_name: I18n.t('users.profile').capitalize } if current_user == @user
  end

  def find_resource
    @user = User.friendly.find(params[:id])
  end

  def authorize_resource
    authorize @user
  end

  def user_params
    @user_params ||= params
      .require(:user)
      .permit(
        :admin_notes,
        :active,
        :available,
        :avatar,
        :company,
        :description,
        :email,
        :phone,
        :location,
        :first_name,
        :headline,
        :interest_list,
        :last_name,
        :password,
        :password_confirmation,
        :password_hash,
        :password_salt,
        :poster,
        :profile_type,
        :invited_by_id,
        :skill_list,
        :username,
        :provider,
        :uid,
        :publishable_key,
        :access_code,
        :github_url,
        :linkedin_url,
        :web_site_url,
        :admin_tag_list,
        :terms_accepted_at,
        :then,
        :area_of_expertise_1,
        :area_of_expertise_2,
        :area_of_expertise_3,
        :slogan,
        :blitz_availability,
        :special_need,
        :ask_meeting_with,
        spoken_local: [],
        communities: [],
        blitz_roles: [],
        blitz_expertises: [],
        spoken_languages_attributes: [
          :id,
          :_destroy,
          :language,
          :language_level,
          :abr
        ]
      )
  end

  def update_stripe_customer
    stripe_temporary_token = params[:stripe_temporary_token]
    stripe_customer = params[:stripe_customer] || @user.stripe_customer
    stripe_customer.source = stripe_temporary_token
    stripe_customer.save
  end

  def verify_employees
    if current_user.has_company.present? && current_user.has_company.permission != "admin"
      redirect_to dashboard_path
    end
  end

end