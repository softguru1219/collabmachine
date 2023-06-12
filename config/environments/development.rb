Rails.application.configure do
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert         = false
    Bullet.bullet_logger = true
    Bullet.console       = true
    # Bullet.growl         = true
    Bullet.rails_logger  = true
    Bullet.add_footer    = true
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false

  # For devise mailer:
  config.action_mailer.default_url_options = {
    host: Figaro.env.default_url_options_host,
    port: Figaro.env.default_url_options_post,
    locale: 'en'
  }

  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true

  config.active_support.deprecation = :raise

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.hosts << "https://01bc-104-223-98-2.ngrok.io"
  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  Paperclip.options[:command_path] = "/usr/local/bin/"

  # Raises error for missing translations
  config.i18n.raise_on_missing_translations = true

  config.active_job.queue_adapter = :inline
  # config.active_job.queue_adapter = :sidekiq

  config.action_view.annotate_rendered_view_with_filenames = true

  config.stripe_webhook_secret = "test_stripe_webhook_secret"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local


  config.hosts << /[a-z0-9-]+\.ngrok\.io/

end
