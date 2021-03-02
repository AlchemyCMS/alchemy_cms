# frozen_string_literal: true

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
