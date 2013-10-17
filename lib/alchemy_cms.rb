require 'rails'

# Instantiate the global Alchemy namespace
module Alchemy
end

if Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR == 0
  require 'alchemy/engine'
else
  raise "Alchemy #{Alchemy::VERSION} needs Rails 4.0 or higher. You are currently using Rails #{Rails::VERSION::STRING}"
end
