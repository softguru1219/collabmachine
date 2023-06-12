class NotificationJob < ActiveJob::Base
  def perform(message)
    pp message
  end
end
