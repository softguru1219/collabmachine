require 'sidekiq/api'

class NotificationMailer
  WAIT_TIME = 15.minutes.freeze

  attr_accessor :user_id

  def initialize(user_id:)
    @user_id = user_id
  end

  def call
    if job
      job.reschedule(WAIT_TIME.from_now)
    else
      MessageMailer.delay_for(WAIT_TIME).latest_activities(user_id)
    end
  end

  private

  def job
    @job ||= jobs.find do |job|
      deserialized_data = Psych.load(job.item['args'].first)
      deserialized_data == [MessageMailer, :latest_activities, [user_id]]
    end
  end

  def jobs
    @jobs ||= Sidekiq::ScheduledSet.new
  end
end
