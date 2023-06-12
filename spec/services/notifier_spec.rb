require 'rails_helper'

describe Notifier do
  describe ".create_messages" do
    it "creates an admin message and a message for the default private user when no options are passed" do
      project = build(:project)

      expected_subject = I18n.t("notifications.projects.creation.user.subject", title: project.title)
      admin_message, private_message = Notifier.create_messages(project, 'creation')

      expect(admin_message.audience).to eq 'admin'
      expect(admin_message.subject).to eq expected_subject

      expect(private_message.audience).to eq 'private'
      expect(private_message.subject).to eq expected_subject
    end

    it "creates an admin message and a message for the user with the passed id when a recipient is passed" do
      project = build(:project)

      expected_subject = I18n.t("notifications.projects.creation.user.subject", title: project.title)
      admin_message, private_message = Notifier.create_messages(project, 'creation', recipient: 1)

      expect(admin_message.audience).to eq 'admin'
      expect(admin_message.subject).to eq expected_subject

      expect(private_message.audience).to eq 'private'
      expect(private_message.subject).to eq expected_subject
      expect(private_message.recipient).to eq 1
    end

    it "creates an admin message when audience admin is passed" do
      project = build(:project)

      expected_subject = I18n.t("notifications.projects.creation.user.subject", title: project.title)
      messages = Notifier.create_messages(project, 'creation', audience: "admin")
      admin_message = messages.first

      expect(admin_message.audience).to eq 'admin'
      expect(admin_message.subject).to eq expected_subject
    end

    it "creates an admin message and a public message with a recipient when audience public is passed" do
      project = build(:project)

      expected_subject = I18n.t("notifications.projects.creation.user.subject", title: project.title)
      admin_message, public_message = Notifier.create_messages(project, 'creation', audience: "public")

      expect(admin_message.audience).to eq 'admin'
      expect(admin_message.subject).to eq expected_subject

      expect(public_message.audience).to eq 'public'
      expect(public_message.subject).to eq expected_subject
      expect(public_message.recipient).to_not be_nil
    end
  end

  describe '.send_messages' do
    let(:user) { create(:user) }
    let(:mission) { create(:mission, project: project) }
    let(:project) { create(:project, user: user) }
    let(:message) do
      create(:message, sender: 0, item: mission)
    end

    context 'when the message is private' do
      before do
        message.update(audience: 'private', recipient: user.id)
      end

      it 'sends an email' do
        Notifier.send_messages([message])

        expect(last_mail.subject).to eq('Recent activities')
        expect(last_mail.to).to eq([user.email])
        expect(last_mail.from).to eq(['support@collabmachine.com'])
        expect(last_mail.body.parts.first.to_s).to include(mission.title)
      end

      it 'sends a desktop notification' do
        expect(NotificationChannel).to receive(:broadcast_to)
          .with(user.id, subject: message.subject, body: message.body)

        Notifier.send_messages([message])
      end
    end

    context 'when the message is public' do
      before do
        message.update(audience: 'public')
      end

      it 'do not send an email' do
        Notifier.send_messages([message])

        expect(last_mail).to be_nil
      end

      it 'sends a desktop notification' do
        expect(NotificationChannel).to receive(:broadcast_to)
          .with('public', subject: message.subject, body: message.body)

        Notifier.send_messages([message])
      end
    end

    context 'when the message is for admin users' do
      before do
        message.update(audience: 'admin')
      end

      it "does not send an email" do
        Notifier.send_messages([message])

        expect(last_mail).to be_nil
      end

      it 'sends a desktop notification' do
        expect(NotificationChannel).to receive(:broadcast_to)
          .with('admin', subject: message.subject, body: message.body)

        Notifier.send_messages([message])
      end
    end
  end

  def last_mail
    ActionMailer::Base.deliveries.last
  end
end
