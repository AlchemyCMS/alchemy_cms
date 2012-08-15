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
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {
      :debug => ENV['CI'] && RUBY_VERSION == "1.8.7"
    })
  end
  Capybara.javascript_driver = :poltergeist
  # Raising the default wait time for capybara requests on ci under ruby 1.8.7
  Capybara.default_wait_time = 5 if ENV['CI'] && RUBY_VERSION == "1.8.7"
  Capybara.register_driver(:rack_test_translated_header) do |app|
    Capybara::RackTest::Driver.new(app, :headers => { 'HTTP_ACCEPT_LANGUAGE' => 'de' })
  end

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
  end

end

if defined?(Spork)
  Spork.prefork { configure }
else
  configure
end
