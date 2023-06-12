class Users::InvitationsController < Devise::InvitationsController
  layout 'empty', only: [:edit, :update]

  respond_to :html, :json

  def create
    if all_valid?
      invite
      render json: { message: send_instructions_message }
    else
      render json: errors, status: :unprocessable_entity
    end
  end

  def edit
    @body_classes = "bg-light full height850"
    super
  end

  # PUT /resource/invitation
  def update
    raw_invitation_token = update_resource_params[:invitation_token]

    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?
    yield resource if block_given?

    if invitation_accepted
      if Devise.allow_insecure_sign_in_after_accept
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message :notice, flash_message if is_flashing_format?
        sign_in(resource_name, resource)
        respond_with resource, location: after_accept_path_for(resource)
      else
        render json: resource.errors, status: :unprocessable_entity
      end
    else

      resource.invitation_token = raw_invitation_token
      render json: resource.errors, status: :unprocessable_entity
    end
  end

  private

  def users
    @users ||= users_attributes.values.map do |attributes|
      attributes.merge!(
        password: User.send(:random_password),
        invited_handle: attributes[:first_name] || attributes[:email],
        invited_by: current_user
      )
      User.new(attributes)
    end
  end

  def users_attributes
    allowed_attributes = { users: [:first_name, :last_name, :email, :invited_handle] }
    @users_attributes ||=
      params.permit(allowed_attributes)[:users] || { 0 => {} }
  end

  def all_valid?
    !users.map(&:valid?).include?(false)
  end

  def invite
    users.each(&:invite!)
  end

  def send_instructions_message
    emails = users.map(&:email)
    I18n.t('devise.invitations.send_instructions', email: emails.to_sentence)
  end

  def errors
    users.map(&:errors)
  end
end
