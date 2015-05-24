if ENV['TRAVIS']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
else
  require 'simplecov'
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  SimpleCov.start 'rails'
end

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'
require 'rails/test_help'
require 'capybara/poltergeist'
require 'capybara/rails'
require 'database_cleaner'
require 'rspec-activemodel-mocks'

require 'alchemy/seeder'
require 'alchemy/test_support/controller_requests'
require 'alchemy/test_support/essence_shared_examples'
require 'alchemy/test_support/integration_helpers'
require 'alchemy/test_support/factories'

require_relative "support/hint_examples.rb"
require_relative "support/transformation_examples.rb"
require_relative "support/rspec-activemodel-mocks_patch.rb"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!
# Disable rails loggin for faster IO. Remove this if you want to have a test.log
Rails.logger.level = 4

# Configure capybara for integration testing
Capybara.default_driver = :rack_test
Capybara.default_selector = :css
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app)
end
Capybara.javascript_driver = :poltergeist
Capybara.ignore_hidden_elements = false

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include Alchemy::Engine.routes.url_helpers
  config.include Alchemy::TestSupport::ControllerRequests, type: :controller
  [:controller, :feature].each do |type|
    config.include Alchemy::TestSupport::IntegrationHelpers, type: type
  end
  config.include FactoryGirl::Syntax::Methods

  config.use_transactional_fixtures = false
  # Make sure the database is clean and ready for test
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    Alchemy::Shell.silence!
    Alchemy::Seeder.seed!
  end

  # All specs are running in transactions, but feature specs not.
  config.before(:each) do |example|
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
    if RSpec.current_example.metadata[:type] == :feature
      allow(Alchemy::Seeder).to receive(:puts)
      Alchemy::Seeder.seed!
    end
  end
end
