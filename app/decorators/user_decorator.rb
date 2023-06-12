class UserDecorator < Draper::Decorator
  delegate_all

  def recent_projects
    object.projects.joins(missions: :messages)
      .where('messages.created_at >= ?', 24.hours.ago)
      .distinct
  end
end
