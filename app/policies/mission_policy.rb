class MissionPolicy < AuthenticatedPolicy
  def is_my_mission?
    user.id == record.project.user_id
  end

  def admin_or_mine?
    user.admin? || is_my_mission?
  end

  def assigned_to_me?
    record.applicants.where(state: "assigned").pluck(:user_id).include?(user.id)
  end

  def suggested_to_me?
    record.applicants.where(state: "suggested").pluck(:user_id).include?(user.id)
  end

  def paid?
    record.invoices.select { |i| i.paid? == false }.empty?
  end

  # determine si on affiche sur la page d'index ou pas
  def index?
    return true if admin_or_mine?
    return true if assigned_to_me?
    return true if record.open_for_candidates? and not record.on_hold

    false
  end

  def show?
    return true if admin_or_mine?
    return true if assigned_to_me?
    return true if suggested_to_me?
    return true if record.open_for_candidates? and not record.on_hold

    false
  end

  def create?
    user.gte_premium?
  end

  def update?
    admin_or_mine?
  end

  def destroy?
    admin_or_mine?
  end
  # def destroy?
  #   if record.project.missions.length == 1
  #     return false
  #   else
  #     return true
  #   end
  # end

  def apply?
    user.gte_premium?
  end

  def show_feed_tab?
    admin_or_mine? or assigned_to_me?
  end

  # state machine
  def mark_mission_reviewed?
    user.admin?
  end

  def open_mission_for_candidates?
    admin_or_mine?
  end

  def submit_mission_for_review?
    admin_or_mine?
  end

  def start?
    admin_or_mine? or assigned_to_me?
  end

  def finish?
    admin_or_mine? or assigned_to_me?
  end

  def reopen?
    admin_or_mine? or assigned_to_me?
  end

  def close?
    admin_or_mine?
  end

  def archive?
    admin_or_mine?
  end

  def hold?
    admin_or_mine?
  end

  # pl [8:23 PM]
  # "[...] si la mission est startée, on peut pas dé-assigner gratis"
  # (sur Slack, le 2016-11-26)
  def unassign?
    if record.started?
      user.admin? # Don't want users to act like jerks with our people
    else
      admin_or_mine? # if not started yet, you can unassign yourself
    end
  end

  # button show / hide
  def show_submit_for_review_button?
    admin_or_mine? and record.draft?
  end

  def show_mark_reviewed_button?
    user.admin? and record.for_review?
  end

  def show_open_for_candidate_button?
    admin_or_mine? && record.reviewed?
  end

  def show_assign_directly?
    admin_or_mine? && record.reviewed?
  end

  def show_start_button?
    user.admin? or (record.assigned? and assigned_to_me? && %w(assigned).include?(record.state))
  end

  def show_mark_completed_button?
    user.admin? or (assigned_to_me? && record.started?)
  end

  def show_reopen_button?
    user.admin? or (assigned_to_me? && %w(finished invoiced).include?(record.state))
  end

  def show_send_invoice_button?
    user.admin? or (assigned_to_me? && record.finished?)
  end

  def show_confirm_paid_button?
    user.admin? or (assigned_to_me? && record.paid?)
  end

  def show_archive_mission_button?
    admin_or_mine? && %w(draft for_review open_for_candidates assigned started finished invoiced).include?(record.state) && paid?
  end

  def show_on_hold_button?
    admin_or_mine?
  end

  def show_referal_info?
    admin_or_mine? || record.project.user.invited_by_id == user.id
  end

  def show_slack_notify_new_mission_button?
    # return true if user.admin?
    admin_or_mine?
  end

  def slack_notify_new_mission?
    admin_or_mine?
  end

  def sort?
    admin_or_mine?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        # restrict to mission coming from current user's projects
        # fixme: take care of 'open_for_candidates' missions
        scope.by_user(user.id)
      end
    end
  end
end
