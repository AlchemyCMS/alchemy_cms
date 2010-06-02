$:.unshift(File.dirname(__FILE__) + '/../..')
$:.unshift(File.dirname(__FILE__) + '/../../lib')
schema_file = File.join(File.dirname(__FILE__), '..', 'schema.rb')
ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/test_process'
require 'action_controller/integration'
require 'init'

config = YAML::load(IO.read(File.join(File.dirname(__FILE__), '..', 'database.yml')))[ENV['DB'] || 'test']
ActiveRecord::Base.configurations = config
ActiveRecord::Base.establish_connection(config)

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/models.log")
ActionController::Base.logger = Logger.new(File.dirname(__FILE__) + "/controllers.log")

load(schema_file) if File.exist?(schema_file)

Test::Unit::TestCase.fixture_path = File.join(File.dirname(__FILE__), '..', 'fixtures')
$:.unshift(Test::Unit::TestCase.fixture_path)

class Test::Unit::TestCase
  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = true

  # Add more helper methods to be used by all tests here...
end
