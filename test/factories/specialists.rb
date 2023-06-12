FactoryBot.define do
  factory :specialist do
    first_name { "MyString" }
    last_name { "MyString" }
    pseudo { "MyString" }
    linkedin { "MyString" }
    french { false }
    english { false }
    others_languages { "MyString" }
    sector { "MyString" }
    software { "MyString" }
    active { false }
    user { nil }
  end
end
