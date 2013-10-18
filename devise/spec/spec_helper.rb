# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require "rspec/rails"
require "capybara/rails"
require 'factory_girl'
require 'alchemy/test_support/auth_helpers'
require 'alchemy/test_support/controller_requests'
require 'alchemy/test_support/integration_helpers'
require 'alchemy/test_support/factories'
require_relative 'support/factories'

ActionMailer::Base.default_url_options[:host] = "test.com"
Capybara.default_driver = :rack_test
Capybara.default_selector = :css
Capybara.ignore_hidden_elements = false

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include Alchemy::TestSupport::AuthHelpers
  config.include Alchemy::TestSupport::ControllerRequests, :type => :controller
  config.include Alchemy::TestSupport::IntegrationHelpers, :type => :feature
  config.include Alchemy::Engine.routes.url_helpers
  config.include FactoryGirl::Syntax::Methods
end
