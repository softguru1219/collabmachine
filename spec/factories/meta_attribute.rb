require 'pry'

FactoryBot.define do
  factory :meta_attribute do
    name { "an_attribute" }
    value { "an_attribute_value" }
    visibility { "private" }
    association :user
    source_user_id { 1 }
  end
end
