FactoryBot.define do
  factory :purchase do
    user
    state { "processed" }
  end
end
