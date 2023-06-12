require 'pry'

FactoryBot.define do
  factory :applicant, class: Applicant do
    state { 'unknown' }
    # association :user, factory: :user
  end
end
