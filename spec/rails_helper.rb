# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require "pundit/rspec"
require 'sidekiq/api'
require 'vcr'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'selenium/webdriver'
require_relative 'feature_helper'
require 'sidekiq/testing'

require 'simplecov'
SimpleCov.start

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.server = :puma, { Silent: true }

Capybara.register_driver :selenium_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: {
      args: %w(headless disable-gpu window-size=900,1200 no-sandbox),
      w3c: false
    },
    'goog:loggingPrefs' => { browser: 'ALL' }
  )

  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities
end

Capybara.javascript_driver = :selenium_chrome
Capybara.asset_host = 'http://localhost:3000' unless ENV['CI']

I18n.locale = :en
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include FactoryBot::Syntax::Methods

  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include FeatureHelper, type: :feature

  config.include ::Rails::Controller::Testing::TestProcess, type: :controller
  config.include ::Rails::Controller::Testing::TemplateAssertions, type: :controller
  config.include ::Rails::Controller::Testing::Integration, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include FactoryHelpers

  config.after(:each, js: true) do
    errors = page.driver.browser.manage.logs.get(:browser)

    # Only occurs in test env
    tawk_cors_errors = [
      "Access to script at 'https://embed.tawk.to/5eb8c53e8ee2956d739fe0c6/default'",
      "https://embed.tawk.to/5eb8c53e8ee2956d739fe0c6/default - Failed to load resource: net::ERR_FAILED"
    ]

    printing_errors = errors.map(&:message).reject { |e| tawk_cors_errors.any? { |s| e.include?(s) } }

    if printing_errors.any?
      message = printing_errors.join("\n\n")
      pp "JAVASCRIPT ERROR: #{message}"
    end
  end

  config.before(:each) do
    Sidekiq::Extensions.enable_delay!
    Sidekiq::Testing.fake! # fake is the default mode
    Sidekiq::Testing.inline!
    Sidekiq::ScheduledSet.new.clear
  end

  config.before(:each, type: :feature) do
    default_url_options[:locale] = nil
  end

  if Bullet.enable?
    config.before(:each) do
      Bullet.start_request
    end

    config.after(:each) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end

  config.around(:each) do |example|
    if example.metadata[:vcr]
      VCR.configure { |c| c.allow_http_connections_when_no_cassette = true }

      example.run

      VCR.configure { |c| c.allow_http_connections_when_no_cassette = false }
    else
      example.run
    end
  end
end

module AutoJS
  def feature(*, js: false, **)
    js = !!ENV['CI'] if js == :either
    super
  end
end
RSpec.singleton_class.prepend AutoJS

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.default_cassette_options = { record: :new_episodes }
  config.configure_rspec_metadata!

  driver_urls = Webdrivers::Common.subclasses.map do |driver|
    URI.parse(driver.base_url).host
  end
  config.ignore_hosts(*driver_urls) # don't block capybara internal requests when VCR is disabled
  config.ignore_localhost = true

  config.allow_http_connections_when_no_cassette = false

  config.filter_sensitive_data('<STRIPE_SECRET_KEY>') { Rails.configuration.stripe[:secret_key] }

  config.filter_sensitive_data('<TEST_STRIPE_CONNECT_PROFILE_UID>') {
    Rails.application.config.test_stripe_connect_profile_uid
  }
  config.filter_sensitive_data('<TEST_STRIPE_CUSTOMER_ID_WITH_SOURCE>') {
    Rails.application.config.test_stripe_customer_id_with_source
  }
  config.filter_sensitive_data('<TEST_STRIPE_CUSTOMER_ID_WITHOUT_SOURCE>') {
    Rails.application.config.test_stripe_customer_id_without_source
  }
  config.filter_sensitive_data('<TEST_STRIPE_CUSTOMER_ID_WITH_ACTIVE_SUBSCRIPTION>') {
    Rails.application.config.test_stripe_customer_id_with_active_subscription
  }
  config.filter_sensitive_data('<TEST_STRIPE_CUSTOMER_ID_WITHOUT_ACTIVE_SUBSCRIPTION>') {
    Rails.application.config.test_stripe_customer_id_without_active_subscription
  }
  config.filter_sensitive_data('<TEST_PREMIUM_SUBSCRIPTION_PRICE_ID>') {
    Rails.application.config.test_premium_subscription_price_id
  }
end
