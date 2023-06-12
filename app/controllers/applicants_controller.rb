class ApplicantsController < ApplicationController
  after_action :verify_authorized

  def destroy_suggestions
    authorize Applicant
    Applicant.where(mission_id: params[:mission_id], user_id: current_user.id, state: 'suggested').destroy_all
    redirect_to mission_path(params[:mission_id]), notice: 'Application was successfully removed.'
  end

  def toggle_im_interested_to_mission
    authorize Applicant
    applicant = Applicant.where(mission_id: params[:mission_id], user_id: current_user.id)
    if applicant.count > 0
      Notifier.call(applicant.first, :removed)
      applicant.destroy_all
    else
      applicant = Applicant.new
      applicant.mission_id = params[:mission_id]
      applicant.user_id = current_user.id
      applicant.state = Applicant.states.unknown
      applicant.save
    end

    # required to update UI (ajax)
    @mission = Mission.find(params[:mission_id])
    @count = Applicant.where(mission_id: params[:mission_id]).count
    @assignments = Applicant.where(mission_id: @mission.id, state: "assigned")
    @im_interested = Applicant.where(mission_id: @mission.id, user_id: current_user.id).any?
    @suggested = Applicant.where(mission_id: @mission.id, user_id: current_user.id, state: 'suggested').any?
    @referal_id = User.find(@mission.project_user_id).invited_by_id

    respond_to do |format|
      format.js { render layout: false, status: :ok }
    end
  end

  def set_applicant_state
    authorize Applicant

    state = params[:state]
    applicant = Applicant.find(params[:id])
    @mission = applicant.mission

    if state == 'assigned'
      if applicant.mission.assigned?
        flash.now[:notice] = "Ooops! Already assigned to somebody. <br>Remove assignment first, then assign somebody new to this mission.".html_safe
        respond_to do |format|
          format.js { render layout: false, status: :unprocessable_entity }
        end
      else
        applicant.update(state: state)
        applicant.mission.assign

        flash.now[:success] = "Assigned!"

        MessageMailer.assigned_mission(applicant)

        respond_to do |format|
          format.js { render layout: false, status: :ok }
        end
      end

    else # unknown, keep, rejected
      applicant.update(state: state)
      Notifier.call(applicant, :update)

      # if was assigned.....re-open for candidates
      unless applicant.mission.assigned?
        applicant.mission.invite_candidates
        flash.now[:alert] = "Little bell: Nobody assigned on your project. (actual state: '#{applicant.mission_state}')"
      end

      respond_to do |format|
        format.js { render layout: false, status: :ok }
      end
    end
  end

  def admin_set_applicant
    authorize Applicant

    mission = Mission.find(params[:mission_id])
    user_id = params[:user_id]
    pointer_id = params[:pointed_by]
    suggested_count = pointer_id ? Applicant.where(mission_id: mission.id, pointed_by: pointer_id).count : 0

    mission.unassign

    if user_id.empty?
      # do cleanup in assignements
    elsif suggested_count < 5
      known_applicant = Applicant.find_by(
        user_id: user_id,
        mission_id: mission.id
      )
      state = pointer_id ? 'suggested' : 'assigned'

      if known_applicant
        known_applicant.update(state: state, pointed_by: pointer_id)
      else
        Applicant.create!(
          mission_id: mission.id,
          user_id: user_id,
          state: state,
          pointed_by: pointer_id
        )
      end
      mission.assign unless pointer_id

      if pointer_id
        flash.now[:success] = I18n.t('applicant.sugestion_recieved')

        # TODO: uncomment for production
        MessageMailer.prepare_suggested_for_mission(User.find(user_id), User.find(pointer_id), mission)
      end
    else
      flash.now[:alert] = I18n.t('applicant.sugestion_recieved_max')
    end

    # if was assigned.....re-open for candidates
    unless mission.assigned? or pointer_id
      mission.invite_candidates
      flash.now[:alert] = "Little bell: Nobody assigned on your project. (actual state: '#{mission.state}')"
    end

    @mission = Mission.includes(:applicants).where(id: params[:mission_id]).order('applicants.state ASC').first
    @assignments = Applicant.where(mission_id: @mission.id, state: "assigned")
    @im_interested = Applicant.where(mission_id: @mission.id, user_id: current_user.id).any?
    @suggested = Applicant.where(mission_id: @mission.id, user_id: current_user.id, state: 'suggested').any?
    @referal_id = User.find(@mission.project_user_id).invited_by_id

    respond_to do |format|
      format.js { render layout: false, status: :ok }
    end
  end

  private

  def find_resource
    @applicant = Applicant.find(params[:id])
  end

  def create_resource
    @applicant = Applicant.new
  end

  def create_with_params
    @applicant = Applicant.new(applicant_params)
  end

  def applicant_params
    params[:applicant]
  end
end
