begin
  require 'simplecov'
  SimpleCov.start('rails') do
    add_filter "/spec/"
  end
rescue LoadError => e
end

begin
  require 'spork'
rescue LoadError => e
end

def configure
  # Configure Rails Environment
  ENV["RAILS_ENV"] = "test"

  require File.expand_path("../dummy/config/environment.rb", __FILE__)

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
  # Disable rails loggin for faster IO. Remove this if you want to have a test.log
  Rails.logger.level = 4

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
    config.use_transactional_fixtures = true
    # Make sure the database is clean and ready for test
    config.before(:suite) do
      truncate_all_tables
      Alchemy::Seeder.seed!
    end
    # Ensuring that the locale is always resetted to :en before running any tests
    config.before(:each) do
      Alchemy::Site.current = nil
      ::I18n.locale = :en
    end
  end

end

if defined?(Spork)
  Spork.prefork { configure }
else
  configure
end
