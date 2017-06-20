require 'simplecov'
if ENV['TRAVIS']
  require 'codeclimate-test-reporter'
end
SimpleCov.start 'rails' do
  add_filter "/lib/alchemy/sass_support"
  add_filter "/lib/alchemy/upgrader"
  add_filter "/lib/alchemy/version"
  add_filter "/lib/rails"
end

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rspec/rails'
require 'capybara/poltergeist'
require 'capybara/rails'
require 'database_cleaner'
require 'rspec-activemodel-mocks'

require 'alchemy/seeder'
require 'alchemy/test_support/controller_requests'
require 'alchemy/test_support/config_stubbing'
require 'alchemy/test_support/essence_shared_examples'
require 'alchemy/test_support/integration_helpers'
require 'alchemy/test_support/factories'
require 'alchemy/test_support/shared_contexts'
require 'alchemy/test_support/shared_uploader_examples'

require_relative 'factories'
require_relative "support/hint_examples.rb"
require_relative "support/transformation_examples.rb"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

ActiveSupport::Deprecation.silenced = true

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

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
  end
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Alchemy::Engine.routes.url_helpers
  config.include Alchemy::TestSupport::ControllerRequests, type: :controller
  config.include Alchemy::TestSupport::ConfigStubbing
  [:controller, :feature, :request].each do |type|
    config.include Alchemy::TestSupport::IntegrationHelpers, type: type
  end
  config.include FactoryGirl::Syntax::Methods

  config.use_transactional_fixtures = false
  # Make sure the database is clean and ready for test
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
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
  end
end
