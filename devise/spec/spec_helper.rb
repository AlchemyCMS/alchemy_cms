# frozen_string_literal: true

require "simplecov"
if ENV["TRAVIS"]
  require "codeclimate-test-reporter"
end
SimpleCov.start "rails" do
  add_filter "/lib/alchemy/devise/version"
  add_filter "/lib/generators"
end

require "rspec/core"

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
