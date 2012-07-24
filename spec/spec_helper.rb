begin
  require 'spork'
rescue LoadError => e
end

def configure
  # Configure Rails Environment
  ENV["RAILS_ENV"] = "test"

  require File.expand_path("../dummy/config/environment.rb", __FILE__)

  require 'database_cleaner'
  DatabaseCleaner.strategy = :truncation

  require 'authlogic/test_case'
  include Authlogic::TestCase

  require "rails/test_help"
  require "rspec/rails"
  require 'factory_girl'
  require 'factories.rb'

  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.default_url_options[:host] = "test.com"

  Rails.backtrace_cleaner.remove_silencers!

  # Configure capybara for integration testing
  require "capybara/rails"
  require 'capybara/poltergeist'
  Capybara.default_driver = :rack_test
  Capybara.default_selector = :css
  Capybara.javascript_driver = :poltergeist

  # Load support files
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

  RSpec.configure do |config|
    require 'rspec/expectations'
    config.include RSpec::Matchers
    config.include Alchemy::Engine.routes.url_helpers
    config.mock_with :rspec
    config.use_transactional_fixtures = false
  end

end

def seed
  # This code will be run each time you run your specs.
  DatabaseCleaner.clean
  # Seed the database
  Alchemy::Seeder.seed!
  ::I18n.locale = :en
end

if defined?(Spork)
  Spork.prefork { configure }
  Spork.each_run { seed }
else
  configure
  seed
end
