class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def stripe_connect
    auth_data = request.env["omniauth.auth"]
    @user = current_user
    if @user.persisted?
      @user.profiles.find_or_create_by(provider: auth_data.provider, uid: auth_data.uid)
      @user.access_code = auth_data.credentials.token
      @user.publishable_key = auth_data.info.stripe_publishable_key
      @user.save

      flash[:notice] = 'Stripe Account Created And Connected'
      redirect_path = session[:stripe_connect_redirect_path] || new_invoice_path
      redirect_to redirect_path
    else
      session["devise.stripe_connect_data"] = request.env["omniauth.auth"]
      redirect_to dashboard_path
    end
  end

  def linkedin
    auth_data = request.env["omniauth.auth"]
    if current_user
      import_data_from_linkedin(current_user, auth_data)
      current_user.profiles.find_or_create_by(provider: auth_data.provider, uid: auth_data.uid)
      redirect_to edit_user_path(current_user)
    else
      @user = User.from_omniauth(auth_data)
      if @user.save
        import_data_from_linkedin(@user, auth_data)
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "Linkedin")
      else
        session["devise.linkedin_data"] = auth_data
        render "devise/registrations/new"
      end
    end
  end

  def failure
    # If we do get failures we should probably handle them more explicitly than just rerouting to root. To review in the future with colo
    redirect_to root_path
  end

  private

  def import_data_from_linkedin(user, auth_data)
    LinkedinProfileImporter.new(user: user, token: auth_data.credentials.token).call
  end
end
