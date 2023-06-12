require 'pry'

FactoryBot.define do
  factory :mission, class: Mission do
    title { 'Mission for project The new project title' }
    description { '' }
  end
end
