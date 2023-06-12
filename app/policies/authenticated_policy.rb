class AuthenticatedPolicy < ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user.present?

    super(user, record)
  end
end
