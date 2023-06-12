class PurchasePolicy < AuthenticatedPolicy
  def index?
    true
  end

  def show?
    user.admin? || record.user_id == user.id
  end
end
