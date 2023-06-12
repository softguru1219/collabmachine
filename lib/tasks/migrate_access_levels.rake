task migrate_access_levels: :application do
  User.where(access_level: "newcomer").each do |user|
    puts "migrating newcomers:"
    puts user.email

    user.update!(access_level: User.access_levels.freemium)
  end

  User.where(access_level: "member").update_all(access_level: User.access_levels.freemium)
end
