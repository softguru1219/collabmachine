task flush_old_sessions: :environment do
  cutoff = DateTime.now - 60.days
  scope = ActiveRecord::SessionStore::Session.where("updated_at < ?", DateTime.now - 60.days)

  puts "Flushing #{scope.count} sessions older than #{cutoff}"

  scope.delete_all

  puts "#{ActiveRecord::SessionStore::Session.count} sessions remain."
end
