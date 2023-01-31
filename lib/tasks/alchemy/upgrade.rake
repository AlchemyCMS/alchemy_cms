# frozen_string_literal: true
require "alchemy/upgrader"
require "alchemy/version"

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    "alchemy:upgrade:prepare",
    "alchemy:upgrade:7.0:run",
  ] do
    Alchemy::Upgrader.display_todos
  end

  namespace :upgrade do
    desc "Alchemy Upgrader: Prepares the database and updates Alchemys configuration file."
    task prepare: [
      "alchemy:upgrade:database",
      "alchemy:upgrade:config",
      "alchemy:upgrade:package",
    ]

    desc "Alchemy Upgrader: Prepares the database."
    task database: [
      "alchemy:install:migrations",
      "db:migrate",
    ]

    desc "Alchemy Upgrader: Copy configuration file."
    task config: [:environment] do
      Alchemy::Upgrader.copy_new_config_file
    end

    desc "Alchemy Upgrader: Install new Node package."
    task package: [:environment] do
      Alchemy::Upgrader.update_npm_package
    end

    desc "Upgrade Alchemy to v7.0"
    task "7.0" => [
      "alchemy:upgrade:prepare",
      "alchemy:upgrade:7.0:run",
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace "7.0" do
      task "run" => [
        "alchemy:upgrade:7.0:update_admin_entrypoint",
      ]

      desc "Update alchemy admin entrypoint"
      task update_admin_entrypoint: [:environment] do
        puts "adding npm_package..."
        Alchemy::Upgrader::SevenPointZero.update_admin_entrypoint
      end
    end
  end
end
