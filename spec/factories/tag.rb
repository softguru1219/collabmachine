FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "tag_#{n}" }
    taggings_count { 0 }
    sequence(:position)
    language { "en" }
  end
end
