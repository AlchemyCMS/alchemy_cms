# frozen_string_literal: true
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
      'alchemy:upgrade:5.0:install_gutentag_migrations',
      'alchemy:install:migrations',
      'db:migrate',
      'alchemy:db:seed'
    ]

    desc "Alchemy Upgrader: Copy configuration file."
    task config: [:environment] do
      Alchemy::Upgrader.copy_new_config_file
    end

    desc 'Upgrade Alchemy to v5.0'
    task '5.0' => [
      'alchemy:upgrade:prepare'
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace '5.0' do
      desc 'Install Gutentag migrations'
      task install_gutentag_migrations: [:environment] do
        Alchemy::Upgrader::FivePointZero.install_gutentag_migrations
      end
    end
  end
end
