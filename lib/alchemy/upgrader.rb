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

    def initialize(version)
      super()
      self.class.include VERSION_MODULE_MAP[version.to_s].constantize
    end

    def update_config
      desc "Copy configuration file."

      template("templates/alchemy.rb.tt", "config/initializers/alchemy.rb")
    end
  end
end
