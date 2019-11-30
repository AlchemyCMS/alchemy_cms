require 'alchemy/upgrader'
require 'alchemy/version'

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    'alchemy:upgrade:prepare'
  ] do
    Alchemy::Upgrader.display_todos
  end

  namespace :upgrade do
    desc 'Alchemy Upgrader: Prepares the database and updates Alchemys configuration file.'
    task prepare: [
      'alchemy:upgrade:database',
      'alchemy:upgrade:config'
    ]

    desc "Alchemy Upgrader: Prepares the database."
    task database: [
      'alchemy:install:migrations',
      'db:migrate',
      'alchemy:db:seed'
    ]

    desc "Alchemy Upgrader: Copy configuration file."
    task config: [:environment] do
      Alchemy::Upgrader.copy_new_config_file
    end
  end
end
