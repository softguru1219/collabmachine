class UserMessagePolicy < AuthenticatedPolicy
  def index?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def update?
    user.admin?
  end

  def new?
    true
  end

  def create?
    user.gte_premium?
  end

  def show?
    user.admin?
  end

  class Scope
    def resolve
      scope
    end
  end
end
