class UserStepsEntrepreneurController < ApplicationController
  include BlitzHelper
  include Wicked::Wizard

  layout 'empty'
  steps :infos, :dispo, :dispo_other, :details, :experiences

  def show
    @body_classes = 'bg-light'

    @user = current_user
    render_wizard
  end

  def edit
    @user = current_user
    jump_to(:infos)
  end

  def update
    @user = current_user
    @user.admin_tag_list.add next_blitz_tag

    # might create problems having the guy in two roles (2 sheets)
    @user.blitz_roles.push('entrepreneur') unless @user.blitz_roles.include?('entrepreneur') or @user.blitz_roles.include?('Entrepreneur')
    @user.blitz_roles.uniq!

    params[:skill_list] = params[:skill_list].joins(', ') if params[:skill_list]
    params[:interest_list] = params[:interest_list].joins(', ') if params[:interest_list]
    params[:user][:blitz_availability] = set_blitz_availability(params[:user][:blitz_availability]) if step == :dispo

    @user.update(user_params)

    jump_to(:details) if step == :dispo && params[:user][:blitz_availability] != []

    render_wizard @user
  end

  private

  def set_blitz_availability(selection)
    case selection
    when "Toute la journée (9h à 17h)"
      ['9h00', '9h45', '10h20', '11h00', '11h30', '13h00', '13h30', '14h10', '14h45', '15h20', '15h55', '16h30']
    when "Avant-midi (9h à 12h)"
      ['9h00', '9h45', '10h20', '11h00', '11h30']
    when "Après-midi (13h à 17h)"
      ['13h00', '13h30', '14h10', '14h45', '15h20', '15h55', '16h30']
    else # 'Autre place (SVP préciser)'
      []
    end
  end

  def finish_wizard_path
    # user_path(current_user)
    blitz_coaching_path
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
        :slogan,
        :phone,
        :username,
        :github_url,
        :linkedin_url,
        :web_site_url,
        :special_need,
        :ask_meeting_with,
        :area_of_expertise_1,
        :area_of_expertise_2,
        :area_of_expertise_3,
        communities: [],
        blitz_availability: [],
        skill_list: [],
        interest_list: []
    )
  end
end
