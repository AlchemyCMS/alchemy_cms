# Include this file insted of spec_helper, if you don't need database and other slow stuff
ENV["RAILS_ENV"] = "test"
ENV["FAST_SPECS"] = 'true'

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require "rspec/rails"

Rails.logger.level = 4

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
