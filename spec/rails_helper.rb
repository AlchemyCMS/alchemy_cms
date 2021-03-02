# frozen_string_literal: true

require_relative "./spec_helper"

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative("dummy/config/environment.rb")

require "capybara/rails"
require "capybara-screenshot/rspec"
require "rails-controller-testing"
require "rspec-activemodel-mocks"
require "rspec/rails"
require "webdrivers/chromedriver"
require "shoulda-matchers"
require "factory_bot"

require "alchemy/seeder"
require "alchemy/test_support"
require "alchemy/test_support/config_stubbing"
require "alchemy/test_support/essence_shared_examples"
require "alchemy/test_support/integration_helpers"
require "alchemy/test_support/shared_contexts"
require "alchemy/test_support/shared_uploader_examples"

require_relative "support/calculation_examples.rb"
require_relative "support/hint_examples.rb"
require_relative "support/transformation_examples.rb"
require_relative "support/capybara_helpers.rb"
require_relative "support/custom_news_elements_finder"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Alchemy::Deprecation.silenced = false

Rails.backtrace_cleaner.remove_silencers!
# Disable rails loggin for faster IO. Remove this if you want to have a test.log
Rails.logger.level = 4

# Configure capybara for integration testing
Capybara.default_selector = :css
Capybara.ignore_hidden_elements = false

FactoryBot.definition_file_paths.append(Alchemy::TestSupport.factories_path)
FactoryBot.find_definitions

Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << "--headless"
    opts.args << "--disable-gpu" if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << "--disable-site-isolation-trials"
    opts.args << "--window-size=1280,800"
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Alchemy::Engine.routes.url_helpers
  config.include Alchemy::TestSupport::ConfigStubbing
  [:controller, :system, :request].each do |type|
    config.include Alchemy::TestSupport::IntegrationHelpers, type: type
  end
  config.include FactoryBot::Syntax::Methods
  config.include CapybaraSelect2, type: :system

  config.use_transactional_fixtures = true

  # All specs are running in transactions, but feature specs not.
  config.before(:each) do
    Alchemy::Site.current = nil
    Alchemy::Language.current = nil
    ::I18n.locale = :en
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.when_first_matching_example_defined(type: :system) do
    config.before :suite do
      # Preload assets
      # This should avoid capybara timeouts, and avoid counting asset compilation
      # towards the timing of the first feature spec.
      start = Time.now
      puts "Preloading assets."
      Rails.application.precompiled_assets
      puts "Done in #{(Time.now - start).round(2)}s"
    end
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end
end
