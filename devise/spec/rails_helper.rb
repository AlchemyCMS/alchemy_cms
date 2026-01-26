# frozen_string_literal: true

require_relative "spec_helper"

# Configure Rails Environment
ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails-controller-testing"
require "rspec/rails"
require "rspec/active_model/mocks"
require "capybara/rspec"
require "capybara-screenshot/rspec"
require "factory_bot_rails"
require "alchemy/test_support/integration_helpers"
require "alchemy/test_support/config_stubbing"

require "alchemy/test_support"
FactoryBot.definition_file_paths.append(Alchemy::TestSupport.factories_path)
FactoryBot.reload

require "alchemy/devise/test_support/factories"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_headless
Capybara.default_selector = :css
Capybara.ignore_hidden_elements = false
ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Alchemy::Engine.routes.url_helpers
  config.include Alchemy::TestSupport::ConfigStubbing
  config.include FactoryBot::Syntax::Methods
  config.include ActiveJob::TestHelper
  [:controller, :feature, :request].each do |type|
    config.include Alchemy::TestSupport::IntegrationHelpers, type: type
  end
  # TODO Remove when Devise fixes https://github.com/heartcombo/devise/issues/5705
  if Rails.application.respond_to?(:reload_routes_unless_loaded)
    config.before(:each, type: :controller) do
      Rails.application.reload_routes_unless_loaded
    end
  end
end
