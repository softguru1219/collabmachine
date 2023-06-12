class ApplicantPolicy < AuthenticatedPolicy
  # TODO: audit these permissions
  # this policy was a purely mechanical migration from the previous situation: any authenticated user could do anything
  # we wanted to lock down destructive actions to premium and above

  def destroy_suggestions?
    user.gte_premium?
  end

  def toggle_im_interested_to_mission?
    user.gte_freemium?
  end

  def admin_set_applicant?
    user.gte_premium?
  end

  def set_applicant_state?
    user.gte_premium?
  end
end
