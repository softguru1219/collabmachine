module Notifier
  extend self

  def call(model, event_type, **options)
    messages = create_messages(model, event_type, **options)
    send_messages(messages)
  end

  def create_messages(model, type, audience: Message.audiences.private, recipient: nil)
    attributes = {
      item: model,
      message_type: model.state,
      sender: model.notification_default_sender,
      subject: build_subject(model, type)
    }

    case audience
    when Message.audiences.private
      [
        Message.create(attributes.merge(audience: Message.audiences.admin)),
        Message.create(attributes.merge(audience: Message.audiences.private,
                                        recipient: recipient || model.notification_default_recipient))
      ]
    when Message.audiences.public
      [
        Message.create(attributes.merge(audience: Message.audiences.admin)),
        Message.create(attributes.merge(audience: Message.audiences.public,
                                        recipient: recipient || model.notification_default_recipient))
      ]
    when Message.audiences.admin
      [
        Message.create(attributes.merge(audience: Message.audiences.admin))
      ]
    end
  end

  def build_subject(model, event_type)
    model_type = model.class.to_s.tableize
    I18n.t("notifications.#{model_type}.#{event_type}.admin.subject", model.notification_attributes)
  end

  def send_messages(messages)
    messages.each do |message|
      send_mail(message)
      send_desktop_notification(message)
    end
  end

  private

  # private messages get sent via email
  def send_mail(message)
    NotificationMailer.new(user_id: message.recipient).call if message.audience_is_private? && message.recipient
  end

  def send_desktop_notification(message)
    data = {
      subject: message.subject,
      body: message.body
    }

    recipient = message.audience_is_private? ? message.recipient : message.audience
    NotificationChannel.broadcast_to(recipient, data)
  end
end
