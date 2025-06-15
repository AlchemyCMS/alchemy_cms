# frozen_string_literal: true

require "alchemy/upgrader"
require "alchemy/version"

Upgrader = Alchemy::Upgrader.new("8.0")

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    "alchemy:upgrade:prepare",
    "alchemy:upgrade:8.0:run"
  ] do
    Upgrader.display_todos
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

    desc "Alchemy Upgrader: Update configuration file."
    task config: [:environment] do
      Upgrader.update_config
    end

    namespace "8.0" do
      task "run" => [
        "alchemy:upgrade:8.0:mention_alchemy_config_initializer"
      ]

      task :mention_alchemy_config_initializer do
        Upgrader.mention_alchemy_config_initializer
      end
    end
  end
end
