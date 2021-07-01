# frozen_string_literal: true
require "alchemy/upgrader"
require "alchemy/version"

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    "alchemy:upgrade:prepare",
    "alchemy:upgrade:5.0:run",
    "alchemy:upgrade:6.0:run",
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
    end

    desc "Upgrade Alchemy to v6.0"
    task "6.0" => [
      "alchemy:upgrade:prepare",
      "alchemy:upgrade:6.0:run",
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace "6.0" do
      task "run" => [
        "alchemy:upgrade:6.0:create_public_page_versions",
        "alchemy:upgrade:6.0:create_ingredients",
      ]

      desc "Create public page versions"
      task create_public_page_versions: [:environment] do
        Alchemy::Upgrader::SixPointZero.create_public_page_versions
      end

      desc "Create ingredients for elements with ingredients defined"
      task create_ingredients: [:environment] do
        Alchemy::Upgrader::SixPointZero.create_ingredients
      end
    end
  end
end
