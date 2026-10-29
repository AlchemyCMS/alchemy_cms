# frozen_string_literal: true

require "importmap-rails"
require "alchemy/configurations/main"

module Alchemy
  YAML_PERMITTED_CLASSES = %w[Symbol Date Regexp]

  # JS Importmap instance
  singleton_class.attr_accessor :importmap
  self.importmap = Importmap::Map.new

  mattr_accessor :storage_adapter

  class << self
    def config
      @_config ||= Alchemy::Configurations::Main.new
    end
    delegate :configure, to: :config
  end
end
