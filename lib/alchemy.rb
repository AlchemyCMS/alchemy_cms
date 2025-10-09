# frozen_string_literal: true

require "alchemy/admin/preview_url"
require "importmap-rails"
require "alchemy/configurations/main"
require "alchemy/config_missing"

module Alchemy
  include Alchemy::ConfigMissing
  extend Alchemy::ConfigMissing

  YAML_PERMITTED_CLASSES = %w[Symbol Date Regexp]

  # JS Importmap instance
  singleton_class.attr_accessor :importmap
  self.importmap = Importmap::Map.new

  mattr_accessor :storage_adapter

  class << self
    def config
      @_config ||= Alchemy::Configurations::Main.new
    end

    def configure(&blk)
      yield config
    end

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

    # Configure tabs in the link dialog
    #
    # With this configuration that tabs in the link dialog can be extended
    # without overwriting or defacing the Admin Interface.
    #
    # == Example
    #
    #    # components/acme/link_tab.rb
    #    module Acme
    #      class LinkTab < ::Alchemy::Admin::LinkDialog::BaseTab
    #        def title
    #          "Awesome Tab Title"
    #        end
    #
    #        def name
    #          :unique_name
    #        end
    #
    #        def fields
    #           [ title_input, target_select ]
    #        end
    #      end
    #    end
    #
    #    # config/initializers/alchemy.rb
    #    Alchemy.link_dialog_tabs << Acme::LinkTab
    #
    def link_dialog_tabs
      @_link_dialog_tabs ||= Set.new([
        Alchemy::Admin::LinkDialog::InternalTab,
        Alchemy::Admin::LinkDialog::AnchorTab,
        Alchemy::Admin::LinkDialog::ExternalTab,
        Alchemy::Admin::LinkDialog::FileTab
      ])
    end
  end
end
