require 'pry'

FactoryBot.define do
  factory :user_message, class: UserMessage do
    title { "Recommendation" }
    message { "Hi, this is a recommendation" }
    anonymous { true }
  end
end
