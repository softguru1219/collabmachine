class Users::RegistrationController < Devise::RegistrationsController
  include BlitzHelper

  skip_before_action :require_no_authentication, only: [:new, :create, :cancel, :sign_in]
  prepend_before_action :check_captcha, only: [:create]
  layout 'empty'

  def create

    @body_classes = 'bg-light'

    build_resource(sign_up_params)
    @registration_type = params[:registration_type]

    resource.access_level = User.access_levels.freemium

    resource.blitz_roles = [@registration_type] if %w[coach entrepreneur].include?(@registration_type)

    resource.skip_password_validation = true if @registration_type == "employee"

    resource.save

    UsersCompany.create(company_id: current_user.id, user_id: resource.id) if @registration_type == "employee" and current_user.present?

    yield resource if block_given?
    if resource.persisted?

      if next_blitz_tag
        resource.tap do |user|
          user.admin_tag_list.add next_blitz_tag
          user.save
        end
      end

      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource), notice: ""
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def no_signup; end

  protected

  def response_to_sign_up_failure(resource)
    if resource.email == "" && resource.password.nil?
      redirect_to root_path, alert: "Please fill in the form"
    elsif User.pluck(:email).include? resource.email
      redirect_to root_path, alert: "email already exists"
    end
  end

  def after_inactive_sign_up_path_for(_resource)
    MessageMailer.prepare_new_user(resource)
    root_path
  end

  def after_sign_up_path_for(_resource)
    MessageMailer.prepare_new_user(resource)

    case @registration_type
    when 'talent'
      user_steps_talent_path(:details)
    when 'client'
      user_steps_client_path(:details)
    when 'coach'
      user_steps_coach_path(:infos)
    when 'entrepreneur'
      user_steps_entrepreneur_path(:infos)
    else
      user_steps_path
    end
  end

  private

  def check_captcha
    unless verify_recaptcha
      self.resource = resource_class.new sign_up_params
      resource.validate # Look for any other validation errors besides Recaptcha
      set_minimum_password_length
      respond_with_navigational(resource) { render :new }
    end
  end
end
