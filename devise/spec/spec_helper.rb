# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)

require "rails/test_help"
require "rspec/rails"

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end
