class NotifyAdminReviewJob < ApplicationJob
  queue_as :default

  def perform(mission)
    # Do something later
    @mission = mission
    MessageMailer.notify_admin_mission_review(@mission)
  end
end
