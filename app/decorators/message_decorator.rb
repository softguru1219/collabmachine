class MessageDecorator < Draper::Decorator
  delegate_all

  def state_classes
    ['item'].tap do |classes|
      classes << 'disabled' if message.deprecated
    end
  end

  def can_be_viewed_by?(user)
    object.audience_is_public? ||
      (object.audience_is_private? && object.user_recipient == user) ||
      (object.audience_is_admin? && user.admin?)
  end
end
