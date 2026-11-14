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
  require "alchemy/config_missing"

  include Alchemy::ConfigMissing
  extend Alchemy::ConfigMissing

  YAML_PERMITTED_CLASSES = %w[Symbol Date Regexp]

  # JS Importmap instance
  singleton_class.attr_accessor :importmap
  self.importmap = Importmap::Map.new

  mattr_accessor :storage_adapter

  class << self
    def config
      require "alchemy/configurations/main"
      @_config ||= Alchemy::Configurations::Main.new
    end
    delegate :configure, to: :config

    enable_searchable_deprecation_msg = "Use `Alchemy.config.show_page_searchable_checkbox` instead."
    def enable_searchable = config.show_page_searchable_checkbox
    deprecate :enable_searchable= => enable_searchable_deprecation_msg, :deprecator => Alchemy::Deprecation

    def enable_searchable=(other)
      config.show_page_searchable_checkbox = other
    end
    deprecate enable_searchable: enable_searchable_deprecation_msg, deprecator: Alchemy::Deprecation

    delegate :preview_sources, to: :config
    delegate :preview_sources=, to: :config
    deprecate preview_sources: "Use `Alchemy.config.preview_sources` instead.", deprecator: Alchemy::Deprecation
    deprecate :preview_sources= => "Use `Alchemy.config.preview_sources=` instead.", :deprecator => Alchemy::Deprecation

    delegate :admin_js_imports, to: :config
    delegate :admin_js_imports=, to: :config
    deprecate admin_js_imports: "Use `Alchemy.config.admin_js_imports` instead", deprecator: Alchemy::Deprecation
    deprecate :admin_js_imports= => "Use `Alchemy.config.admin_js_imports=` instead", :deprecator => Alchemy::Deprecation

    delegate :admin_importmaps, to: :config
    deprecate admin_importmaps: "Use Alchemy.config.admin_importmaps instead", deprecator: Alchemy::Deprecation

    delegate :admin_stylesheets, to: :config
    deprecate admin_stylesheets: "Use Alchemy.config.admin_stylesheets instead", deprecator: Alchemy::Deprecation

    delegate :publish_targets, to: :config
    deprecate publish_targets: "Use Alchemy.config.publish_targets instead", deprecator: Alchemy::Deprecation

    delegate :link_dialog_tabs, to: :config
    deprecate link_dialog_tabs: "Use Alchemy.config.link_dialog_tabs instead", deprecator: Alchemy::Deprecation
  end
end

# Require globally used Alchemy mixins
require_relative "alchemy/auth_accessors"
require_relative "alchemy/cache_digests/template_tracker"
require_relative "alchemy/deprecation"
require_relative "alchemy/error_tracking"
require_relative "alchemy/errors"
require_relative "alchemy/forms/builder"
require_relative "alchemy/i18n"
require_relative "alchemy/logger"
require_relative "alchemy/modules"
require_relative "alchemy/on_page_layout"
require_relative "alchemy/on_page_layout/callbacks_runner"
require_relative "alchemy/paths"
require_relative "alchemy/tinymce"
require_relative "alchemy/version"

# Finally require Alchemy itself
require_relative "alchemy/engine"
