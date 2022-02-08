# frozen_string_literal: true

return if caller.find do |line|
  line.include?("/factory_bot/find_definitions.rb")
end

Alchemy::Deprecation.warn <<~MSG
  Please require factories using FactoryBots preferred approach:

      # spec/rails_helper.rb

      require 'alchemy/test_support'

      FactoryBot.definition_file_paths.append(Alchemy::TestSupport.factories_path)
      FactoryBot.find_definitions
MSG

Dir["#{File.dirname(__FILE__)}/factories/*.rb"].sort.each do |file|
  require file
end
