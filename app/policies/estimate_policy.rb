class EstimatePolicy < AuthenticatedPolicy
  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  def show?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  class Scope
    def resolve
      scope
    end
  end
end
