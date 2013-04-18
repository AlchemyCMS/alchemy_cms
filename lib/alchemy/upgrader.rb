module Alchemy
  class Upgrader < Alchemy::Seeder
    class << self

      # Runs ugrades
      #
      # Set UPGRADE env variable to only run a specific task.
      def run!
        if ENV['UPGRADE']
          ENV['UPGRADE'].split(',').each do |task|
            self.send(task)
          end
        else
          run_all
        end
        display_todos
      end

      def run_all
        Rake::Task['alchemy:install:migrations'].invoke
        Rake::Task['db:migrate'].invoke
        Seeder.seed!
        copy_new_config_file
      end

    private

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
