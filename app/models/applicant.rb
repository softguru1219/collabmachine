class Applicant < ApplicationRecord
  acts_as_paranoid

  belongs_to :mission
  delegate :title, :state, to: :mission, prefix: true, allow_nil: true

  belongs_to :user
  delegate :first_name, :last_name, to: :user, prefix: true, allow_nil: true

  string_enum :state, %w(
    unknown
    assigned
    rejected
    suggested
  )

  after_create :after_application

  def after_application
    Notifier.call(self, :creation, recipient: self.mission.project_user_id)
  end

  def notification_default_sender
    self.mission.project_user_id
  end

  def notification_default_recipient
    self.user_id
  end

  def notification_attributes
    {
      title: self.mission_title,
      first_name: self.user_first_name,
      last_name: self.user_last_name,
      mission_id: self.mission.id,
      state: self.state
    }
  end
end
