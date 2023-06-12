class TagPolicy < AuthenticatedPolicy
  def destroy?
    user.admin?
  end

  def update?
    user.admin?
  end

  def merge?
    user.admin?
  end

  def create?
    user.gte_premium?
  end

  def show?
    true
  end

  def tag_cloud?
    user.admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
