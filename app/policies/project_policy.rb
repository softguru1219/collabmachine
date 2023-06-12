class ProjectPolicy < AuthenticatedPolicy
  def my_project?
    user.id == record.user_id
  end

  def admin?
    user.admin?
  end

  def admin_or_mine?
    return true if user.admin?
    return true if my_project?

    false
  end

  # determine si on affiche sur la page d'index ou pas
  def index?
    return true if admin_or_mine?

    # return true if record.open_for_candidates?
    # return true if assigned_to_me? # not sure yet
    false
  end

  def show?
    return true if Rails.env.production? and record.id == 149
    return true if Rails.env.development? and record.id == 2

    admin_or_mine? or record.missions.any?(&:open_for_candidate) or record.visibility_scope == 'public'
  end

  def give_link?
    admin_or_mine?
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

  def hold?
    admin_or_mine?
  end

  def mark_project_reviewed?
    admin_or_mine?
  end

  def show_referal_info?
    admin_or_mine? || record.project.user.invited_by_id == user.id
  end

  def open_project_for_candidates?
    admin_or_mine?
  end

  def show_delete_button?
    admin_or_mine?
  end

  def show_edit_button?
    admin_or_mine?
  end

  def show_on_hold_button?
    admin_or_mine?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        Project
          .where(user_id: user.id)
          .or(Project.assigned_to(user))
          .or(Project.where(id: Project.with_open_missions))
      end
    end
  end
end
