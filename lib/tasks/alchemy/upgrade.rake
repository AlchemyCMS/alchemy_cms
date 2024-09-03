# frozen_string_literal: true

require "alchemy/upgrader"
require "alchemy/version"

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    "alchemy:upgrade:prepare",
    "alchemy:upgrade:7.0:run",
    "alchemy:upgrade:7.3:run"
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

    desc "Upgrade Alchemy to v7.0"
    task "7.0" => [
      "alchemy:upgrade:prepare",
      "alchemy:upgrade:7.0:run"
    ] do
      Alchemy::Upgrader.display_todos
    end

    desc "Upgrade Alchemy to v7.3"
    task "7.3" => [
      "alchemy:upgrade:prepare",
      "alchemy:upgrade:7.3:run"
    ] do
      Alchemy::Upgrader.display_todos
    end

    namespace "7.0" do
      task "run" => [
        "alchemy:upgrade:7.0:remove_admin_entrypoint"
      ]

      desc "Remove alchemy admin entrypoint"
      task remove_admin_entrypoint: [:environment] do
        puts "removing npm_package..."
        Alchemy::Upgrader::SevenPointZero.remove_admin_entrypoint
      end
    end

    namespace "7.3" do
      task "run" => [
        "alchemy:upgrade:7.3:remove_admin_stylesheets",
        "alchemy:upgrade:7.3:generate_custom_css_entrypoint"
      ]

      desc "Remove alchemy admin stylesheets"
      task remove_admin_stylesheets: [:environment] do
        Alchemy::Upgrader::SevenPointThree.remove_admin_stylesheets
      end

      desc "Generate custom css entrypoint"
      task generate_custom_css_entrypoint: [:environment] do
        Alchemy::Upgrader::SevenPointThree.generate_custom_css_entrypoint
      end
    end
  end
end
