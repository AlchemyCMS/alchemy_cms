# frozen_string_literal: true

# Require globally used external libraries
require "acts_as_list"
require "action_view/dependency_tracker"
require "active_model_serializers"
require "active_storage/engine"
require "awesome_nested_set"
require "cancan"
require "gutentag"
require "importmap-rails"
require "kaminari"
require "ransack"
require "simple_form"
require "turbo-rails"
require "userstamp"
require "view_component"

# Instantiate the global Alchemy namespace
module Alchemy
  YAML_PERMITTED_CLASSES = %w[Symbol Date Regexp]

  # JS Importmap instance
  singleton_class.attr_accessor :importmap
  self.importmap = ::Importmap::Map.new

  mattr_accessor :storage_adapter

  class << self
    def config
      require "alchemy/configurations/main"
      @_config ||= Alchemy::Configurations::Main.new
    end
    delegate :configure, to: :config
  end
end

# Require globally used Alchemy mixins
require_relative "alchemy/cache_digests/template_tracker"
require_relative "alchemy/deprecation"
require_relative "alchemy/error_tracking"
require_relative "alchemy/errors"
require_relative "alchemy/forms/builder"
require_relative "alchemy/i18n"
require_relative "alchemy/logger"
require_relative "alchemy/on_page_layout"
require_relative "alchemy/on_page_layout/callbacks_runner"
require_relative "alchemy/paths"
require_relative "alchemy/tinymce"
require_relative "alchemy/version"

# Finally require Alchemy itself
require_relative "alchemy/engine"
