# frozen_string_literal: true

require_relative "spec_helper"

# Configure Rails Environment
ENV["RAILS_ENV"] ||= "test"
ENV["ALCHEMY_LIQUID"] = "true"

require_relative "../../spec/dummy/config/environment"
require "rspec/rails"
require "factory_bot"
require "alchemy/test_support"
require "alchemy/test_support/config_stubbing"
require "alchemy/test_support/integration_helpers"

FactoryBot.definition_file_paths.append(Alchemy::TestSupport.factories_path)
FactoryBot.find_definitions

Dir[File.join(__dir__, "support", "**", "*.rb")].each { require _1 }

# Liquid versions of a few dummy app views. Prepended, so they win over the
# dummy app's ERB partials of the same name.
FIXTURE_VIEWS = File.expand_path("fixtures/views", __dir__)
ActionController::Base.prepend_view_path(FIXTURE_VIEWS)

Rails.logger.level = 4

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.include Alchemy::Engine.routes.url_helpers
  config.include Alchemy::TestSupport::ConfigStubbing
  config.include FactoryBot::Syntax::Methods
  config.include LiquidHelpers
  [:controller, :request].each do |type|
    config.include Alchemy::TestSupport::IntegrationHelpers, type: type
  end

  config.before(:each) do
    Alchemy::Current.site = nil
    ::I18n.locale = :en
  end

  config.after(:each) do
    Alchemy::Current.reset
  end

  config.before(:each, type: :helper) do
    helper.lookup_context.prepend_view_paths([FIXTURE_VIEWS])
    helper.extend(
      Alchemy::BaseHelper,
      Alchemy::ElementsHelper,
      Alchemy::ElementsBlockHelper,
      Alchemy::PagesHelper
    )
  end
end
