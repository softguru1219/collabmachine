class MessagePolicy < AuthenticatedPolicy
  def is_my_message?
    user.id == record.recipient
  end

  def admin_or_mine?
    user.admin? || is_my_message?
  end

  # determine si on affiche sur la page d'index ou pas
  # message/index
  def index?
    return true if admin_or_mine? or
      record.audience_is_public? or
      record.applicants.where(state: "assigned").pluck(:user_id).include?(user.id)

    false
  end

  def show?
    admin_or_mine?
  end

  def create?
    user.gte_premium?
  end

  def update?
    return true if admin_or_mine?
  end

  def destroy?
    return true if admin_or_mine?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
