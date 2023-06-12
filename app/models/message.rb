class Message < ApplicationRecord
  acts_as_paranoid
  self.per_page = 20

  default_scope { order('id DESC') }

  belongs_to :item, polymorphic: true

  validates :audience, presence: true
  validates :subject, presence: true

  delegate :email, to: :user_recipient, prefix: true, allow_nil: true
  delegate :email, to: :user_sender, prefix: true, allow_nil: true

  string_enum :audience, %w(
    public
    private
    admin
  )

  def self.from_last_day
    where('created_at >= ?', 24.hours.ago)
  end

  def self.not_mission
    where.not(item_type: Mission.to_s)
  end

  def self.public_or_private
    where(audience: [audiences.public, audiences.private])
  end

  def user_recipient
    @user_recipient ||= User.find_by(id: recipient)
  end

  def user_sender
    @user_sender ||= User.find_by(id: sender)
  end
end
