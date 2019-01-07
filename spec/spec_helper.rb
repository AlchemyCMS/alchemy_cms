# frozen_string_literal: true

require 'simplecov'
if ENV['TRAVIS']
  require 'codeclimate-test-reporter'
end
SimpleCov.start 'rails' do
  add_filter "/lib/alchemy/sass_support"
  add_filter "/lib/alchemy/upgrader"
  add_filter "/lib/alchemy/version"
  add_filter "/lib/rails"
end

require 'rspec/core'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
