class UserStepsTalentController < ApplicationController
  include Wicked::Wizard
  attr_accessor :yes_newsletter

  steps :details, :experiences

  def show
    @body_classes = 'bg-light'
    @user = current_user
    render_wizard
  end

  def update
    # TODO: make fields mandatory
    @body_classes = 'bg-light'
    @user = current_user

    if step == steps.last
      # if step == :experiences
      params[:skill_list] = params[:skill_list].joins(', ') if params[:skill_list]
      params[:interest_list] = params[:interest_list].joins(', ') if params[:interest_list]
      # If last step
      params[:registration_completed_at] = DateTime.now

      # if yes_newsletter
      # if params[:yes_newsletter] .... then subscribe
    end

    @user.update_attributes(user_params)
    render_wizard @user
  end

  private

  def finish_wizard_path
    user_path(current_user)
    flash[:notice] = "Campaign successfully updated"
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
        :yes_newsletter,
        :github_url,
        :linkedin_url,
        :web_site_url,
        :registration_completed_at,
        skill_list: [],
        interest_list: []
    )
  end
end
