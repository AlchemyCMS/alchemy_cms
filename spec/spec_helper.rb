require 'simplecov'
require 'coveralls'

if ENV['CI']
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
else
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end
SimpleCov.start 'rails'

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)

require "rails/test_help"
require "rspec/rails"
require 'factory_girl'

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!
# Disable rails loggin for faster IO. Remove this if you want to have a test.log
Rails.logger.level = 4

require "capybara/rails"
require 'capybara/poltergeist'
require 'alchemy/seeder'
require 'alchemy/test_support/auth_helpers'
require 'alchemy/test_support/controller_requests'
require 'alchemy/test_support/integration_helpers'
require 'alchemy/test_support/factories'
require 'alchemy/test_support/essence_shared_examples'
require_relative "support/hint_examples.rb"

# Configure capybara for integration testing
Capybara.default_driver = :rack_test
Capybara.default_selector = :css
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end
Capybara.register_driver(:rack_test_translated_header) do |app|
  Capybara::RackTest::Driver.new(app, headers: { 'HTTP_ACCEPT_LANGUAGE' => 'de' })
end
Capybara.javascript_driver = :poltergeist
Capybara.ignore_hidden_elements = false

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include Alchemy::Engine.routes.url_helpers
  config.include Alchemy::TestSupport::AuthHelpers
  config.include Alchemy::TestSupport::ControllerRequests, type: :controller
  config.include Alchemy::TestSupport::IntegrationHelpers, type: :feature
  config.include FactoryGirl::Syntax::Methods

  config.use_transactional_fixtures = false
  # Make sure the database is clean and ready for test
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    Alchemy::Seeder.seed!
  end

  # All specs are running in transactions, but feature specs not.
  config.before(:each) do
    Alchemy::Site.current = nil
    ::I18n.locale = :en
    if example.metadata[:type] == :feature
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  # After each spec the database gets cleaned. (via rollback or truncate for feature specs)
  # After every feature spec the database gets seeded so the next spec can rely on that data.
  config.append_after(:each) do
    DatabaseCleaner.clean
    if example.metadata[:type] == :feature
      Alchemy::Seeder.stub(:puts)
      Alchemy::Seeder.seed!
    end
  end
end
