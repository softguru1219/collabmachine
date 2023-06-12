task migrate_paperclip_to_activestorage: :environment do
  # access old attachment locations
  # class PaperclipUser < ApplicationRecord
  #   self.table_name = "users"

  #   has_attached_file :avatar
  #   has_attached_file :poster
  # end

  puts "MIGRATING AVATARS"

  paperclip_users_with_avatars = PaperclipUser.where.not(avatar_file_name: nil)

  paperclip_users_with_avatars.each do |paperclip_user|
    file_path = paperclip_user.avatar.path.gsub("/paperclip_users/", "/users/")
    file_name = File.basename(file_path)
    file = File.open(file_path)

    activestorage_user = User.unscoped.find(paperclip_user.id)

    activestorage_user.avatar.attach(io: file, filename: file_name)
    activestorage_user.save(validate: false)

    if activestorage_user.reload.avatar.attached?
      puts activestorage_user.id
    else
      puts "Missing #{activestorage_user.id}"
      puts file_path
    end
  rescue => e
    puts "Error"
    puts activestorage_user.id
    puts e
  end

  puts "MIGRATING POSTERS"

  paperclip_users_with_posters = PaperclipUser.where.not(poster_file_name: nil)

  paperclip_users_with_posters.each do |paperclip_user|
    file_path = paperclip_user.poster.path.gsub("/paperclip_users/", "/users/")
    file_name = File.basename(file_path)
    file = File.open(file_path)

    activestorage_user = User.unscoped.find(paperclip_user.id)

    activestorage_user.poster.attach(io: file, filename: file_name)
    activestorage_user.save(validate: false)

    if activestorage_user.reload.poster.attached?
      puts activestorage_user.id
    else
      puts "Missing #{activestorage_user.id}"
      puts file_path
    end
  rescue => e
    puts "Error"
    puts activestorage_user.id
    puts e
  end
end

task verify_activestorage_migration: :environment do
  User.where.not(avatar_file_name: nil).with_attached_avatar.each do |user|
    puts "Avatar not attached: #{user.id}" unless user.avatar.attached?
  end

  User.where.not(poster_file_name: nil).with_attached_poster.each do |user|
    puts "Poster not attached: #{user.id}" unless user.poster.attached?
  end
end
