FactoryBot.define do
  factory :user, class: User do
    first_name { "John" }
    last_name  { "Doe" }
    sequence(:email) { |i| "john#{i}@example.com" }
    username { "johndoe" }
    headline { "Someone" }
    company { "TestCompany" }
    description { "test description" }
    password { "password" }
    password_confirmation { "password" }
    terms_accepted_at { true }
    access_level { "partner" }
    remaining_product_recommendations { 100 }
  end

  factory :canditate, class: User do
    first_name { "Ftalent" }
    last_name  { "Ltalent" }
    sequence(:email) { |i| "talent#{i}@example.com" }
    username { "talent" }
    headline { "Someone" }
    password { "qwerty" }
    password_confirmation { "qwerty" }
    terms_accepted_at { true }
  end

  factory :admin, class: User do
    first_name { "Admin" }
    last_name  { "Admin" }
    sequence(:email) { |i| "admin#{i}@example.com" }
    username { "admin" }
    headline { "admin" }
    password { "qwerty" }
    password_confirmation { "qwerty" }
    access_level { "admin" }
    terms_accepted_at { true }
  end

  factory :company, class: User do
    first_name { "Company" }
    last_name  { "Company" }
    sequence(:email) { |i| "company#{i}@example.com" }
    username { "company" }
    profile_type { "company" }
    password { "qwerty" }
    password_confirmation { "qwerty" }
    terms_accepted_at { true }
  end
end
