# frozen_string_literal: true

require "alchemy/upgrader"
require "alchemy/version"

namespace :alchemy do
  desc "Upgrades your app to AlchemyCMS v#{Alchemy::VERSION}."
  task upgrade: [
    "alchemy:upgrade:prepare",
    "alchemy:upgrade:8.0:run",
    "alchemy:upgrade:8.1:run",
    "alchemy:upgrade:8.4:run"
  ] do
    Alchemy::Upgrader["8.4"].run_migrations
    Alchemy::Upgrader["8.4"].display_todos
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

    namespace "8.4" do
      task "run" => [
        "alchemy:upgrade:8.4:add_dragonfly_gem",
        "alchemy:upgrade:8.4:upgrade_nested_elements_rendering",
        "alchemy:upgrade:8.4:notify_attachment_filetypes_default",
        "alchemy:upgrade:8.4:notify_admin_content_security_policy"
      ]

      desc "Add dragonfly gem to the Gemfile if the app uses the dragonfly storage adapter"
      task add_dragonfly_gem: [:environment] do
        Alchemy::Upgrader["8.4"].add_dragonfly_gem
      end

      desc "Rewrite element partials to render nested elements through the block helper"
      task upgrade_nested_elements_rendering: [:environment] do
        Alchemy::Upgrader["8.4"].upgrade_nested_elements_rendering
      end

      desc "Notify about the new attachment upload allowlist default"
      task notify_attachment_filetypes_default: [:environment] do
        Alchemy::Upgrader["8.4"].notify_attachment_filetypes_default
      end

      desc "Notify about the new admin Content Security Policy"
      task notify_admin_content_security_policy: [:environment] do
        Alchemy::Upgrader["8.4"].notify_admin_content_security_policy
      end
    end
  end
end
