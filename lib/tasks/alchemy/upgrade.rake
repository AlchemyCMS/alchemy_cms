# frozen_string_literal: true

require "alchemy/upgrader"
require "alchemy/version"

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    "alchemy:upgrade:prepare",
    "alchemy:upgrade:8.0:run"
  ] do
    Alchemy::Upgrader.display_todos
  end

  namespace :upgrade do
    desc "Alchemy Upgrader: Prepares the database and updates Alchemys configuration file."
    task prepare: [
      "alchemy:upgrade:database",
      "alchemy:upgrade:config"
    ]

    desc "Alchemy Upgrader: Prepares the database."
    task database: [
      "alchemy:install:migrations",
      "db:migrate"
    ]

    desc "Alchemy Upgrader: Copy configuration file."
    task config: [:environment] do
      Alchemy::Upgrader.copy_new_config_file
    end

    namespace "8.0" do
      task "run" => [
        "alchemy:upgrade:8.0:install_active_storage",
        "alchemy:upgrade:8.0:prepare_dragonfly_config",
        "alchemy:upgrade:8.0:migrate_pictures_to_active_storage",
        "alchemy:upgrade:8.0:migrate_attachments_to_active_storage"
      ]

      desc "Install active_storage"
      task :install_active_storage do
        Alchemy::Upgrader::EightZero.install_active_storage
      end

      desc "Prepare Dragonfly config"
      task :prepare_dragonfly_config do
        Alchemy::Upgrader::EightZero.prepare_dragonfly_config
      end

      desc "Migrate pictures to active_storage"
      task :migrate_pictures_to_active_storage do
        Alchemy::Upgrader::EightZero.migrate_pictures_to_active_storage
      end

      desc "Migrate attachments to active_storage"
      task :migrate_attachments_to_active_storage do
        Alchemy::Upgrader::EightZero.migrate_attachments_to_active_storage
      end
    end
  end
end
