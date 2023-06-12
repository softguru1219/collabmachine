class MissionDecorator < Draper::Decorator
  delegate_all

  def notification_link
    h.mission_path(object)
  end
end
