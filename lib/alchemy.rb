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

    # Additional stylesheets to be included in the Alchemy admin UI
    #
    # == Example
    #
    #    # lib/alchemy/devise/engine.rb
    #    initializer "alchemy.devise.stylesheets", before: "alchemy.admin_stylesheets" do
    #      Alchemy.admin_stylesheets << "alchemy/devise/admin.css"
    #    end
    #
    # @return [Set<String>]
    def admin_stylesheets
      @_admin_stylesheets ||= Set.new(["alchemy/admin/custom.css"])
    end

    # Define page publish targets
    #
    # A publish target is a ActiveJob that gets performed
    # whenever a user clicks the publish page button.
    #
    # Use this to trigger deployment hooks of external
    # services in an asychronous way.
    #
    # == Example
    #
    #     # app/jobs/publish_job.rb
    #     class PublishJob < ApplicationJob
    #       def perform(page)
    #         RestClient.post(ENV['BUILD_HOOK_URL'])
    #       end
    #     end
    #
    #     # config/initializers/alchemy.rb
    #     Alchemy.publish_targets << PublishJob
    #
    def publish_targets
      @_publish_targets ||= Set.new
    end

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
