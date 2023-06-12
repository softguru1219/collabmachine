FactoryBot.define do
  factory :message do
    recipient { 0 }
    sender { 0 }
    subject { 'Subject' }
    body { 'Body' }
    audience { 'public' }
  end
end
