# frozen_string_literal: true
require "alchemy/upgrader"
require "alchemy/version"

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    "alchemy:upgrade:prepare",
    "alchemy:upgrade:5.0:run",
  ] do
    Alchemy::Upgrader.display_todos
  end

  namespace :upgrade do
    desc "Alchemy Upgrader: Prepares the database and updates Alchemys configuration file."
    task prepare: [
      "alchemy:upgrade:database",
      "alchemy:upgrade:config",
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

    desc "Upgrade Alchemy to v5.0"
    task "5.0" => [
      "alchemy:upgrade:prepare",
      "alchemy:upgrade:5.0:run",
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace "5.0" do
      task "run" => [
        "alchemy:upgrade:5.0:install_gutentag_migrations",
        "alchemy:upgrade:5.0:remove_layout_roots",
        "alchemy:upgrade:5.0:remove_root_page",
        "alchemy:upgrade:5.0:run_webpacker_installer",
        "alchemy:upgrade:5.0:add_npm_package",
        "alchemy:upgrade:5.0:copy_alchemy_entry_point",
      ]

      desc "Install Gutentag migrations"
      task install_gutentag_migrations: [:environment] do
        Alchemy::Upgrader::FivePointZero.install_gutentag_migrations
      end

      desc "Remove layout root pages"
      task remove_layout_roots: [:environment] do
        Alchemy::Upgrader::FivePointZero.remove_layout_roots
      end

      desc "Remove root page"
      task remove_root_page: [:environment] do
        Alchemy::Upgrader::FivePointZero.remove_root_page
      end

      desc "Run webpacker installer"
      task run_webpacker_installer: [:environment] do
        Alchemy::Upgrader::FivePointZero.run_webpacker_installer
      end

      desc "Add NPM package"
      task add_npm_package: [:environment] do
        puts "adding npm_package..."
        Alchemy::Upgrader::FivePointZero.add_npm_package
      end

      desc "Copy alchemy entry point"
      task copy_alchemy_entry_point: [:environment] do
        puts "copying alchemy entry point"
        Alchemy::Upgrader::FivePointZero.copy_alchemy_entry_point
      end
    end
  end
end
