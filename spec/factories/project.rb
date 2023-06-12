FactoryBot.define do
  factory :project, class: Project do
    title { 'The new project title' }
    description { 'test' }
  end
end
