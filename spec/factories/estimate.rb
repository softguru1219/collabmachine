FactoryBot.define do
  factory :estimate, class: Estimate do
    title { 'The new estimate title' }
    description { 'test' }
    email { 'test@test.com' }
    phone { '1231231234' }
  end
end
