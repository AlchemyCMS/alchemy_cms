# frozen_string_literal: true

require "alchemy/admin/preview_url"
require "importmap-rails"

module Alchemy
  YAML_PERMITTED_CLASSES = %w[Symbol Date Regexp]

  # Define page preview sources
  #
  # A preview source is a Ruby class returning an URL
  # that is used as source for the preview frame in the
  # admin UI.
  #
  # == Example
  #
  #     # lib/acme/preview_source.rb
  #     class Acme::PreviewSource < Alchemy::Admin::PreviewUrl
  #       def url_for(page)
  #         if page.site.name == "Next"
  #           "https://user:#{ENV['PREVIEW_HTTP_PASS']}@next.acme.com"
  #         else
  #           "https://www.acme.com"
  #         end
  #       end
  #     end
  #
  #     # config/initializers/alchemy.rb
  #     require "acme/preview_source"
  #     Alchemy.preview_sources << Acme::PreviewSource
  #
  #     # config/locales/de.yml
  #     de:
  #       activemodel:
  #         models:
  #           acme/preview_source: Acme Vorschau
  #
  def self.preview_sources
    @_preview_sources ||= Set.new << Alchemy::Admin::PreviewUrl
  end

  def self.preview_sources=(sources)
    @_preview_sources = Array(sources)
  end

  # Additional JS modules to be imported in the Alchemy admin UI
  #
  # Be sure to also pin the modules with +Alchemy.importmap+.
  #
  # == Example
  #
  #    Alchemy.importmap.pin "flatpickr/de",
  #      to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/l10n/de.js"
  #
  #    Alchemy.admin_js_imports << "flatpickr/de"
  #
  def self.admin_js_imports
    @_admin_js_imports ||= Set.new
  end

  def self.admin_js_imports=(sources)
    @_admin_js_imports = Set[sources]
  end

  # Additional importmaps from engines to be included in the Alchemy admin UI
  #
  # Be sure to also pin modules with +Alchemy.importmap+.
  #
  # == Example
  #
  #    # config/alchemy/importmap.rb
  #    Alchemy.importmap.pin "alchemy_solidus", to: "alchemy_solidus.js", preload: true
  #    Alchemy.importmap.pin_all_from Alchemy::Solidus::Engine.root.join("app/javascript/alchemy_solidus"),
  #      under: "alchemy_solidus",
  #      preload: true
  #
  #    # lib/alchemy/solidus/engine.rb
  #    initializer "alchemy_solidus.assets", before: "alchemy.importmap" do |app|
  #      Alchemy.engine_importmaps.add(Engine)
  #      app.config.assets.precompile << "alchemy_solidus/manifest.js"
  #    end
  #
  # @return [Set<Rails::Engine>]
  def self.engine_importmaps
    @_engine_importmaps ||= Set.new([Alchemy::Engine])
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
  def self.publish_targets
    @_publish_targets ||= Set.new
  end

  # Enable full text search configuration
  #
  # It enables a searchable checkbox in the page form to toggle
  # the searchable field. These information can used in a search
  # plugin (e.g. https://github.com/AlchemyCMS/alchemy-pg_search).
  #
  # == Example
  #
  #     # config/initializers/alchemy.rb
  #     Alchemy.enable_searchable = true
  #
  mattr_accessor :enable_searchable, default: false

  # JS Importmap instance
  singleton_class.attr_accessor :importmap
  self.importmap = Importmap::Map.new

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
  def self.link_dialog_tabs
    @_link_dialog_tabs ||= Set.new([
      Alchemy::Admin::LinkDialog::InternalTab,
      Alchemy::Admin::LinkDialog::AnchorTab,
      Alchemy::Admin::LinkDialog::ExternalTab,
      Alchemy::Admin::LinkDialog::FileTab
    ])
  end
end
