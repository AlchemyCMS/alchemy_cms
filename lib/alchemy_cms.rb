require 'rails'

if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 2
  require 'alchemy/engine'
else
  raise "Alchemy #{Alchemy::VERSION} needs Rails 3.2 or higher. You are currently using Rails #{Rails::VERSION::STRING}"
end
