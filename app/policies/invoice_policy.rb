class InvoicePolicy < AuthenticatedPolicy
  def mine?
    user.id == record.user_id
  end

  def admin_or_mine?
    return true if user.admin?

    return true if mine?

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
    return true if user.admin?

    return true if record.customer_id == user.id

    false
  end

  def create?
    user.gte_premium?
  end

  def update?
    return false if record.paid?

    admin_or_mine?
  end

  def destroy?
    return false if record.paid?

    admin_or_mine?
  end

  def pay?
    return false if record.paid?

    return true if user.admin?

    return false unless record.user.stripe_profile

    return true if record.customer_id == user.id

    false
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.by_user(user.id)
      end
    end
  end
end
