class OrderPolicy < AuthenticatedPolicy
  def index?
    user.gte_premium?
  end

  def show?
    user.admin? || record.vendor_id == user.id
  end

  def invoice?
    user.admin?
  end
end
