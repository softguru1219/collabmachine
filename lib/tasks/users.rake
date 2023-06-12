# cycle through and update cm profiles with slack data (no picture ?)

namespace :users do
  desc "Find duplicates by email"
  task duplicates_by_email: :environment do
    User.select(:email).group(:email).having("count(email) > 1")
  end

  desc "Rake tasks for users"
  task compile_weights: :environment do
    User.all.each do |u|
      u.compile_weight
      # puts "#{u.full_name}:  #{u.rating}"
      u.save
    end
  end

  task without_referal: :environment do
    puts User.without_referal.pluck('id', 'first_name', 'last_name', 'email')
  end

  task slack_to_collab: :environment do
    require 'net/http'

    # runtime params
    dry_run = false # set to false to save entries at run time
    activation = false
    # runtime params

    client = Slack::Web::Client.new
    avatar_image_path = "#{Rails.root}public/images/dummy_images/"

    created = 0
    existing = 0

    # List members on slack
    slack_members = []
    client.users_list(presence: true, limit: 10) do |response|
      slack_members.concat(response.members)
    end

    slack_members.each do |m|
      current_u = m.profile.email.to_s
      puts "Slack user is: #{current_u} "
      puts "---------------------------------------"

      next if m.is_bot
      next if m.deleted
      next unless m.profile.email

      puts "#{current_u} is real human profile"

      if (found_user = User.find_by_email(m.profile.email))
        existing += 1
        found_user.profiles.find_or_create_by(provider: 'slack', uid: m.id)
        found_user.save
        puts "#{current_u} already in collab. see: #{found_user.first_name} #{found_user.last_name}"
        puts "Skipping..."
      elsif (found_user = Profile.find_by_provider_and_uid('slack',  m.id).try(:user))
        puts "#{current_u} already got a slack profile in Collab Machine. see: #{found_user.first_name} #{found_user.last_name}"
        puts "Skipping..."
      else
        puts "#{current_u} has to be created in Collab Machine."

        if m.profile.is_custom_image
          puts "Profile image to be fetched from slack for #{current_u}."
          unless dry_run
            file_name = "#{m.profile.first_name}_#{m.profile.last_name}.png".sanitize_filename
            destination = Rails.root.join("public", "images", "dummy_images", file_name)
            IO.copy_stream(open(m.profile.image_192), destination)
            puts "Profile image fetched from slack for #{current_u}."
          end
        end

        if dry_run
          created += 1
          puts "User would have been created: #{current_u}"
        else

          u = User.new(
            username: m.profile.display_name_normalized,
            email: m.profile.email,
            password: 'balloc',
            password_confirmation: 'balloc',
            first_name: m.profile.first_name,
            last_name: m.profile.last_name,
            headline: m.profile.title,
            avatar: (File.new("#{avatar_image_path}#{file_name}") if m.profile.is_custom_image | nil),
            balance: 0,
            active: activation
          )
          u.save

          u.profiles.find_or_create_by(provider: 'slack', uid: m.id)
          u.save
          created += 1

          puts "User created: #{current_u}"
        end
      end

      puts "---------------------------------------\n\n"
    end

    puts "Total existing users: #{existing}"
    puts "Total created users: #{created}"
    puts "Run mode: #{dry_run ? 'dry run (nothing created)' : 'not dry run'}"
  end
end
