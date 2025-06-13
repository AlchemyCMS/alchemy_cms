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

    namespace "8.0" do
      task "run" => [
        "alchemy:upgrade:8.0:install_active_storage"
      ]

      desc "Install active_storage"
      task :install_active_storage do
        Alchemy::Upgrader::EightZero.install_active_storage
      end

      desc "Migrate to active_storage"
      task :migrate_to_active_storage, [:service_name] => :environment do
        require "alchemy/storage_migration/active_storage_migration"
        Alchemy::StorageMigration::ActiveStorageMigration.start!(
          service_name: args[:service_name]
        )
      end

      desc "Migrate pictures to active_storage"
      task :migrate_pictures_to_active_storage, [:service_name] => :environment do
        require "alchemy/storage_migration/active_storage_migration"
        Alchemy::StorageMigration::ActiveStorageMigration.migrate_pictures(
          service_name: args[:service_name]
        )
      end

      desc "Migrate attachments to active_storage"
      task :migrate_attachments_to_active_storage, [:service_name] => :environment do
        require "alchemy/storage_migration/active_storage_migration"
        Alchemy::StorageMigration::ActiveStorageMigration.migrate_attachments(
          service_name: args[:service_name]
        )
      end
    end
  end
end
