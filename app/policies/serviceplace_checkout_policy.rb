class ServiceplaceCheckoutPolicy < AuthenticatedPolicy
  def show?
    true
  end

  def confirm_payment_information?
    true
  end

  def update_card?
    true
  end

  def confirm_purchase?
    true
  end

  def do_confirm_purchase?
    true
  end
end
