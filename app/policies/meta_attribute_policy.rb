class MetaAttributePolicy < AuthenticatedPolicy
  def index?
    user.admin?
  end
end
