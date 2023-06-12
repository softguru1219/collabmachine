Rails.application.configure do
  config.after_initialize do
    Bullet.enable        = true
    Bullet.bullet_logger = true
    Bullet.raise         = false # raise an error if n+1 query occurs

    # avoid bullet false positive in Missions#index
    Bullet.add_safelist type: :unused_eager_loading, class_name: "Mission", association: :applicants
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  config.assets.compile = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  config.action_mailer.perform_caching = false

  config.action_mailer.default_url_options = { host: 'collabmachine.com', locale: I18n.default_locale }

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :raise

  config.active_job.queue_adapter = :sidekiq

  config.i18n.default_locale = :en
  config.i18n.raise_on_missing_translations = true
  I18n.locale = config.i18n.locale = config.i18n.default_locale

  config.active_storage.service = :test

  config.cache_store = :null_store

  config.disable_stripe_user_creation = true

  config.stripe_webhook_secret = "test_stripe_webhook_secret"

  # These only need to be set when *recording* VCR specs.
  # On subsequent runs they are replaced with VCR.filter_sensitive_data.
  config.test_stripe_customer_id_with_source = Figaro.env.test_stripe_customer_id_with_source || "FAKE_STRIPE_CUSTOMER_ID_WITH_SOURCE"
  config.test_stripe_customer_id_without_source = Figaro.env.test_stripe_customer_id_without_source || "FAKE_STRIPE_CUSTOMER_ID_WITHOUT_SOURCE"
  config.test_stripe_customer_id_with_active_subscription = Figaro.env.test_stripe_customer_id_with_active_subscription || "FAKE_STRIPE_CUSTOMER_ID_WITH_ACTIVE_SUBSCRIPTION"
  config.test_stripe_customer_id_without_active_subscription = Figaro.env.test_stripe_customer_id_without_active_subscription || "FAKE_STRIPE_CUSTOMER_ID_WITHOUT_ACTIVE_SUBSCRIPTION"
  config.test_premium_subscription_price_id = Figaro.env.test_premium_subscription_price_id || "FAKE_STRIPE_PREMIUM_PRICE_ID"
end
