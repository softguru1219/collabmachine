class DashboardPolicy < AuthenticatedPolicy
  def master_service_agreement?
    user.admin?
  end

  def trousse_participant_automne_2021
    UsersPolicy.new(user).participant_mastermind_automne_2021?
  end
end
