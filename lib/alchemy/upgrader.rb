# frozen_string_literal: true

require "alchemy/shell"
require "thor"

module Alchemy
  class Upgrader
    include Alchemy::Shell
    include Thor::Base
    include Thor::Actions

    Dir["#{File.dirname(__FILE__)}/upgrader/*.rb"].sort.each { require(_1) }

    VERSION_MODULE_MAP = {
      "8.0" => "Alchemy::Upgrader::EightZero"
    }

    source_root Alchemy::Engine.root.join("lib/generators/alchemy/install")

    # Returns a memoized upgrader instance for the given version.
    # This ensures todos are accumulated across rake tasks.
    def self.[](version)
      @instances ||= {}
      @instances[version.to_s] ||= new(version)
    end

    def initialize(version)
      super()
      self.class.include VERSION_MODULE_MAP[version.to_s].constantize
    end

    def update_config
      desc "Copy configuration file."
      @default_config = Alchemy::Configurations::Main.new
      template("templates/alchemy.rb.tt", "config/initializers/alchemy.rb")
    end

    def run_migrations
      ActiveRecord::Migration.check_all_pending!
    rescue ActiveRecord::PendingMigrationError
      desc "Pending Database migrations."
      if yes?("Run database migrations now? (y/N)")
        log "Migrating Database..."
        Rake::Task["db:migrate"].invoke
      else
        log "Don't forget to run database migrations later with rake `db:migrate`.", :skip
      end
    end
  end
end
