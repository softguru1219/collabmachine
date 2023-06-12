source 'https://rubygems.org'

gem 'rails', '~> 6.1.0'

gem 'activerecord-session_store'
gem 'acts-as-taggable-on', github: 'mbleigh/acts-as-taggable-on'
gem 'awesome_print'
gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', require: false
gem 'bootstrap-multiselect-rails'
gem 'bootstrap-sass', '~> 3.3.7'
gem 'carrierwave'
gem 'chart-js-rails' # graphs (usage ???)
gem 'chartkick' # graphs (usage ???)
gem 'clipboard-rails'
gem 'coffee-rails' # (todo: refactor the flush)
gem 'devise', '~> 4.4' # full authentication gem (https://github.com/heartcombo/devise)
gem 'devise-i18n' # translations for devise
gem 'devise_invitable', '1.7.0'
gem 'draper'
gem 'execjs', '~> 2.7'
gem 'figaro' # environment variables
gem 'file_validators'
gem 'filterrific' # filtering gem for active record recorsets
gem 'font-awesome-rails' # used for icons
gem 'friendly_id'
gem 'google-api-client' # used for blitz coaching
gem 'google-cloud-storage', require: false
gem 'globalize', '~> 6.2', '>= 6.2.1'
gem 'jbuilder'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'jquery-ui-rails'
gem 'kramdown' # markdown parser
gem 'libv8', '3.16.14.15'
gem 'linkedin'
gem 'meta-tags'
gem 'mini_magick'
gem 'mimemagic', github: 'mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f' # !!!!! hard fix for mimemagic deprecation.
gem 'mobility'
gem 'image_processing'
gem 'momentjs-rails', '~> 2.11', '>= 2.11.1' # date handling lib
gem 'net-ssh'
gem 'newrelic_rpm'
gem 'nokogiri', '1.11.7'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-oauth2'
gem 'omniauth-stripe-connect'
gem 'paperclip', git: "https://github.com/thoughtbot/paperclip.git"
gem 'paranoia', "~> 2.2" # for soft-deleting stuff
gem 'pg'
gem 'premailer-rails'
gem 'plyr-rails' # play video
gem 'puma'
gem 'pundit' # authorization system (https://github.com/elabs/pundit)
gem 'rack-cors'
gem 'rails-i18n'
gem 'rails_or'
gem 'rake'
gem "rolify" # https://github.com/EppO/rolify // manage roles
gem 'recaptcha', require: 'recaptcha/rails'
gem 'record_tag_helper'
gem 'redactor-rails', github: 'catarse/redactor-rails'
gem 'redis', '~> 3.0'
gem 'responders' # less boilerplate code for responses in controllers
gem 'rubystats' # maths (usage ???)
gem 'sass-rails', '~> 5.0.4'
gem 'sidekiq'
gem 'slack-ruby-client'
gem 'slim-rails'
gem 'sprockets-rails', '>= 2.3.3'
gem 'state_machines'
gem 'state_machines-activerecord'
gem 'store_model'
gem 'stripe'

gem 'trix'
gem 'turbolinks'
gem 'terser'
gem 'underscore-rails', '~> 1.8', '>= 1.8.3'
gem 'vuejs-rails'
gem 'wicked'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'wongi-engine'
gem 'geocoder'
gem 'sitemap_generator'

# see bundle config for local gem override
# using local:
# bundle config local.doc_mate /Users/PL/repo/compute/doc_mate
# gem 'doc_mate', git: 'git@gitlab.com:collabmachine/doc_mate.git', branch: 'master'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano', '3.10.2' # tool for deployment
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-sidekiq'
  gem 'capistrano3-puma'
  gem 'fuubar', require: false
  gem 'hub'
  gem 'metric_fu' # `metric_fu` suite of test for code quality https://github.com/metricfu/metric_fu
  gem 'rails-erd' # generates a map of the database tables and relationship
  gem 'rails_best_practices' # provides a things to improve in the code based on best practices
  gem 'rb-readline'
  gem 'rubocop' # code analysis, showing syntax error in the code base or smells.
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubycritic' # RubyCritic is a gem that wraps around static analysis gems such as Reek, Flay and Flog to provide a quality report of your Ruby code.
  gem 'solargraph'
  gem 'state_machines-graphviz' # generate a graph of your state machine with : rake state_machines:draw CLASS=<Project_or_other>
  gem 'i18n-tasks' # TODO: fix all missing translations using `i18n-tasks missing`
end

group :development, :test do
  gem 'amazing_print'
  gem 'brakeman'
  gem 'bullet' # help with N+1 queries (https://github.com/flyerhzm/bullet)
  gem 'rubocop-rspec', require: false
  gem 'vcr'
  gem 'webmock'
  gem 'letter_opener_web'
end

group :development, :test, :beta do
  gem 'pry-byebug' # debug tool
  gem 'pry-rails' # debug tool
  gem 'faker'
  gem 'factory_bot_rails'
  gem 'byebug'
  gem 'ed25519'
  gem 'bcrypt_pbkdf'
end

group :test do
  gem "capybara"
  gem 'capybara-screenshot'
  gem 'rails-controller-testing'
  gem 'rspec-rails',         '~> 5.0',  require: false
  gem 'simplecov', require: false # producing a report about code coverage on the codebase
  gem 'timecop'
  gem 'webdrivers'
end
