directory '/home/collab/html/production/current'
rackup "/home/collab/html/production/current/config.ru"
environment 'production'

tag ''

pidfile "/home/collab/html/production/shared/tmp/pids/puma.pid"
state_path "/home/collab/html/production/shared/tmp/pids/puma.state"
stdout_redirect '/home/collab/html/production/shared/log/puma_access.log', '/home/collab/html/production/shared/log/puma_error.log', true

threads 0, 16

bind 'unix:///home/collab/html/production/shared/tmp/sockets/puma.sock'

workers 0

prune_bundler

on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = ""
end
