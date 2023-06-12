require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Collab
  class Application < Rails::Application
    config.load_defaults 6.1

    config.secret_key_base = ENV["secret_key_base"]

    config.active_record.belongs_to_required_by_default = false

    # TODO: fix warnings so we can enable this
    # config.active_record.strict_loading_by_default = true

    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    require 'tags_cleaner'
    require 'extensions/string'
    require 'slack-ruby-client'
    require File.join(Rails.root, 'config/environments', 'shared_settings.rb')

    config.assets.paths << "#{Rails}/vendor/assets/fonts"
    config.assets.precompile += %w(*.eot *.svg *.ttf *.woff *.otf fullpage.scss fullpage.js)

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**/**/*.{rb,yml}').to_s]

    # Fallback, default value if per_page is not defined and provided by the model.
    WillPaginate.per_page = 20

    # removing noise like this:
    # Instance method "created?" is already defined in #<Module:0x007ff9c2e74578>, use generic helper instead or set StateMachines::Machine.ignore_method_conflicts = true.
    StateMachines::Machine.ignore_method_conflicts = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local

    I18n.config.available_locales = [:fr, :en]

    config.i18n.default_locale = :fr

    config.i18n.fallbacks = [:en, :fr]
    I18n.locale = config.i18n.locale = config.i18n.default_locale

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.default_url_options = { host: 'collabmachine.com' }
    config.action_mailer.preview_path = "#{Rails.root}/spec/mailer_previews"

    config.disable_stripe_user_creation = false

    config.i18n.fallbacks = { fr: :en, en: :fr }

    # these must be provided in config in order for the seeds to work out of the box with stripe
    # however the app and tests will still generally run if they aren't
    config.test_stripe_connect_profile_uid = Figaro.env.test_stripe_connect_profile_uid || "FAKE_STRIPE_CONNECT_PROFILE_UID"

    config.active_storage.replace_on_assign_to_many = false

    config.stripe_webhook_secret = ENV['stripe_webhook_secret']
    config.stripe_customer_portal_id = ENV['stripe_customer_portal_id']
  end
end
