require 'rails_helper'

describe NotificationMailer do
  let!(:user) { create(:user) }
  let!(:user2) { create(:user) }

  before do
    Sidekiq::Testing.disable!
  end

  describe '#call' do
    context 'when there is no mail in the queue' do
      it 'send a mail in a 15 minutes' do
        NotificationMailer.new(user_id: user.id).call
        expect(jobs.first.at.min).to eq(15.minutes.from_now.min)
      end
    end

    context 'when there is a mail already send' do
      it 'reschedule the job' do
        NotificationMailer.new(user_id: user.id).call
        expect(jobs.first.at.min).to eq(15.minutes.from_now.min)

        Timecop.freeze(1.minute.from_now) do
          NotificationMailer.new(user_id: user.id).call
          expect(jobs.size).to eq 1
          expect(jobs.first.at.min).to eq(15.minutes.from_now.min)
        end

        expect(jobs.first.at.min).to eq(16.minutes.from_now.min)
      end

      it 'reschedule only if it the same user' do
        NotificationMailer.new(user_id: user.id).call
        NotificationMailer.new(user_id: user.id).call
        expect(jobs.size).to eq(1)

        NotificationMailer.new(user_id: user2.id).call
        expect(jobs.size).to eq(2)
      end
    end
  end

  def jobs
    Sidekiq::ScheduledSet.new
  end
end
