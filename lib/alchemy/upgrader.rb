# frozen_string_literal: true
require "alchemy/shell"

module Alchemy
  class Upgrader
    extend Alchemy::Shell

    Dir["#{File.dirname(__FILE__)}/upgrader/*.rb"].sort.each { |f| require f }

    class << self
      def copy_new_config_file
        desc "Copy configuration file."
        config_file = Rails.root.join("config/alchemy/config.yml")
        default_config = File.join(File.dirname(__FILE__), "../../config/alchemy/config.yml")
        if !File.exist? config_file
          log "No configuration file found. Creating it."
          FileUtils.cp default_config, Rails.root.join("config/alchemy/config.yml")
        elsif FileUtils.identical? default_config, config_file
          log "Configuration file already present.", :skip
        else
          log "Custom configuration file found."
          FileUtils.cp default_config, Rails.root.join("config/alchemy/config.yml.defaults")
          log "Copied new default configuration file."
          todo "Check the default configuration file (./config/alchemy/config.yml.defaults) for new configuration options and insert them into your config file.", "Configuration has changed"
        end
      end

      def update_npm_package
        desc "Update npm package."
        if File.exist? Rails.root.join("config/importmap.rb")
          `bin/importmap pin @alchemy_cms/admin@~#{Alchemy.version}`
        elsif File.exist? Rails.root.join("package.json")
          `yarn add @alchemy_cms/admin@~#{Alchemy.version}`
        else
          log("Could not update alchemy admin package! Make sure you have a JS bundler installed", :warning)
        end
      end
    end
  end
end
