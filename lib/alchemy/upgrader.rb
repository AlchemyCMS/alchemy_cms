require 'alchemy/seeder'

module Alchemy
  class Upgrader < Alchemy::Seeder

    Dir["#{File.dirname(__FILE__)}/upgrader/*.rb"].each { |f| require f }

    extend Alchemy::Upgrader::TwoPointNine
    extend Alchemy::Upgrader::TwoPointSix
    extend Alchemy::Upgrader::TwoPointFive
    extend Alchemy::Upgrader::TwoPointFour
    extend Alchemy::Upgrader::TwoPointThree
    extend Alchemy::Upgrader::TwoPointTwo
    extend Alchemy::Upgrader::TwoPointOne
    extend Alchemy::Upgrader::TwoPointZero

    class << self

      # Runs ugrades
      #
      def run!
        upgrade_tasks.each do |task|
          self.send(task)
        end
        display_todos
      end

      # Tasks that should run.
      #
      # Set UPGRADE env variable to only run a specific task.
      #
      # Run +rake alchemy:upgrade:list+ for all available tasks
      #
      def upgrade_tasks
        if ENV['UPGRADE'].present?
          ENV['UPGRADE'].split(',')
        else
          all_upgrade_tasks
        end
      end

      # All available upgrade tasks
      #
      def all_upgrade_tasks
        private_methods - Object.private_methods - superclass.private_methods
      end

    private

      # Setup task
      def setup
        Rake::Task['alchemy:install:migrations'].invoke
        Rake::Task['db:migrate'].invoke
        Seeder.seed!
      end

      def copy_new_config_file
        desc "Copy configuration file."
        config_file = Rails.root.join('config/alchemy/config.yml')
        default_config = File.join(File.dirname(__FILE__), '../../config/alchemy/config.yml')
        if FileUtils.identical? default_config, config_file
          log "Configuration file already present.", :skip
        else
          log "Custom configuration file found."
          FileUtils.cp default_config, Rails.root.join('config/alchemy/config.yml.defaults')
          log "Copied new default configuration file."
          todo "Check the default configuration file (./config/alchemy/config.yml.defaults) for new configuration options and insert them into your config file."
        end
      end

    end
  end
end
