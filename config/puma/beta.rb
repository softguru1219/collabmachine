directory '/home/collab/html/beta/current'
rackup "/home/collab/html/beta/current/config.ru"
environment 'beta'

tag ''

pidfile "/home/collab/html/beta/shared/tmp/pids/puma.pid"
state_path "/home/collab/html/beta/shared/tmp/pids/puma.state"
stdout_redirect '/home/collab/html/beta/shared/log/puma_access.log', '/home/collab/html/beta/shared/log/puma_error.log', true

threads 0, 16

bind 'unix:///home/collab/html/beta/shared/tmp/sockets/puma.sock'

workers 0

prune_bundler

on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = ""
end
