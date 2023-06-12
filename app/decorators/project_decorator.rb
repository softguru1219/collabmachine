class ProjectDecorator < Draper::Decorator
  delegate_all

  def submit_review_confirm_message
    return unless draft_missions.any?

    'All the missions related to this project will be submitted too'
  end

  def recent_missions
    object.missions.joins(:messages)
      .where('messages.created_at >= ?', 24.hours.ago)
      .distinct
  end

  def notification_link
    h.project_path(object)
  end

  private

  def draft_missions
    missions.select(&:draft?)
  end
end
