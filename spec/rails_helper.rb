# frozen_string_literal: true

require_relative "spec_helper"

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative("dummy/config/environment")

require "capybara/rails"
require "capybara-screenshot/rspec"
require "capybara/shadowdom"
require "rails-controller-testing"
require "rspec-activemodel-mocks"
require "rspec/rails"
require "shoulda-matchers"
require "factory_bot"
require "view_component/test_helpers"
require "webmock"

require "alchemy/seeder"
require "alchemy/test_support"
require "alchemy/test_support/capybara_helpers"
require "alchemy/test_support/config_stubbing"
require "alchemy/test_support/having_crop_action_examples"
require "alchemy/test_support/having_picture_thumbnails_examples"
require "alchemy/test_support/relatable_resource_examples"
require "alchemy/test_support/shared_dom_ids_examples"
require "alchemy/test_support/shared_ingredient_examples"
require "alchemy/test_support/shared_ingredient_editor_examples"
require "alchemy/test_support/integration_helpers"
require "alchemy/test_support/rspec_matchers"
require "alchemy/test_support/shared_contexts"
require "alchemy/test_support/shared_link_tab_examples"
require "alchemy/test_support/shared_uploader_examples"
require "alchemy/test_support/current_language_shared_examples"

require_relative "support/file_name_examples"
require_relative "support/hint_examples"
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
  config.include Alchemy::TestSupport::CapybaraHelpers, type: :system
  config.include ViewComponent::TestHelpers, type: :component

  [:controller, :model].each do |type|
    config.include WebMock::API, type: type
  end

  config.use_transactional_fixtures = true

  # All specs are running in transactions, but feature specs not.
  config.before(:each) do
    ::I18n.locale = :en
  end

  config.around(:each, silence_deprecations: true) do |example|
    Alchemy::Deprecation.silence do
      example.run
    end
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do |example|
    screen_size = example.metadata[:screen_size] || [1280, 800]
    driven_by(:selenium, using: :headless_chrome, screen_size: screen_size) do |capabilities|
      capabilities.add_argument("--disable-search-engine-choice-screen")
    end
  end
end
