class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notification:public"
    stream_from "notification:#{current_user.id}"
    stream_from "notification:admin" if current_user.admin?
  end
end
