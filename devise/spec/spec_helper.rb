require 'simplecov'
if ENV['TRAVIS']
  require "codeclimate-test-reporter"
end
SimpleCov.start 'rails' do
  add_filter '/lib/alchemy/devise/version'
  add_filter '/lib/generators'
end

# Configure Rails Environment
ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rspec/rails"
require 'rspec/active_model/mocks'
require "capybara/rails"
require 'factory_bot'
require 'alchemy/seeder'
require 'alchemy/test_support/controller_requests'
require 'alchemy/test_support/integration_helpers'
require 'alchemy/devise/test_support/factories'

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"
Capybara.default_driver = :rack_test
Capybara.default_selector = :css
Capybara.ignore_hidden_elements = false
ActiveJob::Base.queue_adapter = :test

ActiveSupport::Deprecation.silenced = true

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!
  config.use_transactional_fixtures = true
  config.include Devise::TestHelpers, :type => :controller
  config.include Alchemy::TestSupport::ControllerRequests, :type => :controller
  config.include Alchemy::Engine.routes.url_helpers
  config.include FactoryBot::Syntax::Methods
  config.include ActiveJob::TestHelper
  [:controller, :feature, :request].each do |type|
    config.include Alchemy::TestSupport::IntegrationHelpers, type: type
  end
  config.before(:suite) do
    Alchemy::Seeder.seed!
  end
end
