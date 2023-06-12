FactoryBot.define do
  factory :business_sub_domain do
    name_fr { "MyString" }
    name_en { "MyString" }
    display_en { false }
    display_fr { false }
    business_domain { nil }
  end
end
