# frozen_string_literal: true

require "alchemy/upgrader"
require "alchemy/version"

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    "alchemy:upgrade:prepare",
    "alchemy:upgrade:9.0:run"
  ] do
    Alchemy::Upgrader["9.0"].run_migrations
    Alchemy::Upgrader["9.0"].display_todos
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
      Alchemy::Upgrader["9.0"].update_config
    end

    namespace "9.0" do
      task "run" => [
        "alchemy:upgrade:9.0:remove_deprecated_columns"
      ]

      desc "Remove deprecated columns from pages and elements"
      task remove_deprecated_columns: [:environment] do
        Alchemy::Upgrader["9.0"].remove_deprecated_columns
      end
    end
  end
end
