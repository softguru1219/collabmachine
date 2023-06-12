class ApplicantDecorator < Draper::Decorator
  delegate_all

  def notification_link
    h.mission_path(object.mission)
  end
end
