# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

# setting textdomain at first. so it's available everywhere!
require 'fast_gettext'
FastGettext.text_domain = 'alchemy'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rspec/rails"
require 'factory_girl'
require 'database_cleaner'
require 'factories.rb'

require 'authlogic/test_case'
include Authlogic::TestCase

DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

# Using MySQL on Travis CI
if ENV['TRAVIS']
  configs = YAML.load_file('spec/database.yml')
  ActiveRecord::Base.configurations = configs

  db_name = ENV['DB'] || 'mysql'
  ActiveRecord::Base.establish_connection(db_name)
  ActiveRecord::Base.default_timezone = :utc
else
  # Run any available migration
  ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

  # Seed the database
  Alchemy::Seeder.seed!
end

# Load support files
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  require 'rspec/expectations'
  config.include RSpec::Matchers
  config.mock_with :rspec
  config.use_transactional_fixtures = true
end
