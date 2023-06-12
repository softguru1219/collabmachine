FactoryBot.define do
  factory :review do
    content { "MyString" }
    rating { 1 }
    product { nil }
    user { nil }
  end
end
