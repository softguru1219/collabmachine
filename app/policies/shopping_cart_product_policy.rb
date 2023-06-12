class ShoppingCartProductPolicy < AuthenticatedPolicy
  def create?
    true
  end

  def destroy?
    true
  end
end
