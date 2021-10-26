# frozen_string_literal: true

require_relative "tasks/harden_gutentag_migrations"
require "rails/generators"
require "thor"
require "alchemy/install/tasks"
require "alchemy/version"

module Alchemy
  class Upgrader::FivePointZero < Upgrader
  	include Rails::Generators::Actions
  	include Thor::Base
  	include Thor::Actions

  	source_root File.expand_path("../../generators/alchemy/install/files", __dir__)

    class << self
      def install_gutentag_migrations
        desc "Install Gutentag migrations"
        Rake::Task["gutentag:install:migrations"].invoke
        Alchemy::Upgrader::Tasks::HardenGutentagMigrations.new.patch_migrations
        Rake::Task["db:migrate"].invoke
      end

      def remove_layout_roots
        desc "Remove layout root pages"
        layout_roots = Alchemy::Page.where(layoutpage: true).where("name LIKE 'Layoutroot for%'")
        if layout_roots.size.positive?
          log "Removing #{layout_roots.size} layout root pages."
          layout_roots.delete_all
          Alchemy::Page.where(layoutpage: true).update_all(parent_id: nil)
          log "Done.", :success
        else
          log "No layout root pages found.", :skip
        end
      end

      def remove_root_page
        desc "Remove root page"
        root_page = Alchemy::Page.find_by(parent_id: nil, name: "Root")
        if root_page
          Alchemy::Page.where(parent_id: root_page.id).update_all(parent_id: nil)
          root_page.delete
          log "Done.", :success
        else
          log "Root page not found.", :skip
        end
      end

      def run_webpacker_installer
        # Webpacker does not create a package.json, but we need one
        unless File.exist? app_root.join("package.json")
          in_root { run "echo '{}' > package.json" }
        end
        new.rake("webpacker:install", abort_on_failure: true)
      end

      def add_npm_package
        new.run "yarn add @alchemy_cms/admin@~#{Alchemy.version}"
      end

      def copy_alchemy_entry_point
        webpack_config = YAML.load_file(app_root.join("config", "webpacker.yml"))[Rails.env]
        new.copy_file "alchemy_admin.js",
          app_root.join(webpack_config["source_path"], webpack_config["source_entry_path"], "alchemy/admin.js")
      end

      def app_root
        @_app_root ||= Rails.root
      end
    end
  end
end
