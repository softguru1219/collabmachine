namespace :collab do
  desc "The collab stuff"

  task default_pass_for_users: :environment do
    User.update_all(password: 'balloc', password_confirmation: 'balloc')
  end

  task flush: :environment do
    Rake::Task['db:migrate:reset'].invoke
    Rake::Task['db:seed'].invoke

    # Just as if they confirmed their account
    User.find_each do |user|
      user.update(sign_in_count: 1) if user.sign_in_count == 0
    end
  end
end
