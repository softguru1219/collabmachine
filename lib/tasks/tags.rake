namespace :tags do
  desc "Rake tasks for tags"

  desc "delete unused tags"
  task destroy_orphean_tags: :environment do
    TagsCleaner.clean
  end
end
