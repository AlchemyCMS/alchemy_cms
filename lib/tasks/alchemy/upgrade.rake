# frozen_string_literal: true

require "alchemy/upgrader"
require "alchemy/version"

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    "alchemy:upgrade:prepare",
    "alchemy:upgrade:8.0:run",
    "alchemy:upgrade:8.1:run"
  ] do
    Alchemy::Upgrader["8.1"].run_migrations
    Alchemy::Upgrader["8.1"].display_todos
  end

  namespace :upgrade do
    desc "Alchemy Upgrader: Prepares the database and updates Alchemys configuration file."
    task prepare: [
      "alchemy:upgrade:database",
      "alchemy:upgrade:config"
    ]

    desc "Alchemy Upgrader: Prepares the database."
    task database: [
      "alchemy:install:migrations"
    ]

    desc "Alchemy Upgrader: Update configuration file."
    task config: [:environment] do
      Alchemy::Upgrader["8.0"].update_config
    end

    namespace "8.0" do
      task "run" => [
        "alchemy:upgrade:8.0:mention_alchemy_config_initializer"
      ]

      task :mention_alchemy_config_initializer do
        Alchemy::Upgrader["8.0"].mention_alchemy_config_initializer
      end
    end

    namespace "8.1" do
      task "run" => [
        "alchemy:upgrade:8.1:migrate_page_metadata"
      ]

      desc "Migrate page metadata to page versions"
      task migrate_page_metadata: [
        "alchemy:install:migrations",
        "environment"
      ] do
        Alchemy::Upgrader["8.1"].run_migrations
        Alchemy::Upgrader["8.1"].migrate_page_metadata
      end
    end
  end
end
