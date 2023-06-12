class UserStepsController < ApplicationController
  include Wicked::Wizard
  steps :details, :experiences

  def show
    @user = current_user
    render_wizard
  end

  def update
    @user = current_user

    params[:skill_list] = params[:skill_list].joins(', ') if params[:skill_list]
    params[:interest_list] = params[:interest_list].joins(', ') if params[:interest_list]

    @user.update(user_params)
    render_wizard @user
  end

  private

  def finish_wizard_path
    # user_path(current_user)
    new_specialty_path
  end

  def user_params
    @user_params ||= params
      .require(:user)
      .permit(
        :avatar,
        :company,
        :description,
        :email,
        :first_name,
        :headline,
        :last_name,
        :password,
        :password_confirmation,
        :password_hash,
        :password_salt,
        :poster,
        :username,
        :github_url,
        :linkedin_url,
        :web_site_url,
        skill_list: [],
        interest_list: []
    )
  end
end
