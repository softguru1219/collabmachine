class Admin::ProductPolicy < AuthenticatedPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin?
  end
end
