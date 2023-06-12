require 'rails_helper'

describe NotifyAdminReviewJob do
  describe ".perform_later" do
    it "adds the job to the queue" do
      described_class.perform_later(1)
      expect(enqueued_jobs.last[:job]).to eq described_class
    end
  end
end
