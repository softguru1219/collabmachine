FactoryBot.define do
  factory :business_category do
    abr_en { "MyString" }
    abr_fr { "MyString" }
    name_fr { "MyString" }
    name_en { "MyString" }
    display_en { false }
    display_fr { false }
    business_sub_domain { nil }
  end
end
