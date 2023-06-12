class MessageMailerPreview < ActionMailer::Preview
  # http://localhost:3000/rails/mailers/message_mailer/fr/latest_activities
  def latest_activities
    MessageMailer.latest_activities(User.first.id)
  end
end
