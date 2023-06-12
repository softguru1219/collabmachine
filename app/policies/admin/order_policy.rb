class Admin::OrderPolicy < AuthenticatedPolicy
  def index?
    user.admin?
  end
end
