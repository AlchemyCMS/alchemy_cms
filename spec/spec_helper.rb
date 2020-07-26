# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails" do
  add_filter "/lib/alchemy/upgrader"
  add_filter "/lib/alchemy/version"
  add_filter "/lib/generators"
end

require "rspec/core"
require "webmock"

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include WebMock::API, type: :controller
end
