# frozen_string_literal: true

require "simplecov"
if ENV["GITHUB_ACTIONS"]
  require "simplecov-cobertura"
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

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
  config.pattern = "**/*_spec.rb"
  config.filter_run :focus
  config.include WebMock::API, type: :controller
end
