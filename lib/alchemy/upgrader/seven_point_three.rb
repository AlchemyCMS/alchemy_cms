# frozen_string_literal: true

require "fileutils"
require "thor"

module Alchemy
  class Upgrader::SevenPointThree < Upgrader
    include Thor::Base
    include Thor::Actions

    source_root Alchemy::Engine.root.join("lib/generators/alchemy/install/files")

    class << self
      def remove_admin_stylesheets
        if File.exist? "vendor/assets/stylesheets/alchemy/admin/all.css"
          log "Removing Alchemy admin stylesheets."
          FileUtils.rm_f "vendor/assets/stylesheets/alchemy/admin/all.css"
        end
      end

      def generate_custom_css_entrypoint
        if File.exist? "app/assets/config/manifest.js"
          log "Generating alchemy/admin/custom.css entrypoint file."
          task.copy_file "custom.css", "app/assets/stylesheets/alchemy/admin/custom.css"
          task.append_to_file "app/assets/config/manifest.js", "//= link alchemy/admin/custom.css\n"
          todo(<<~TODO, "Custom styles have been moved to `app/assets/alchemy/admin/custom.css`")
            Check the new `app/assets/alchemy/admin/custom.css` file for any custom styles you might
            have added to the old `vendor/assets/stylesheets/alchemy/admin/all.css` file.
          TODO
        end
      end

      def show_resource_table_notice
        custom_modules = Alchemy::Modules.alchemy_modules.reject { _1["engine_name"] == "alchemy" }
        return if custom_modules.none?

        todo(<<~TODO, "Resource templates have been updated.")
          We updated the resource templates to use the newly introduced
          `Alchemy::Admin::Resource::Table` view component.

          Please update your resource templates accordingly.
        TODO
      end

      private

      def task
        @_task || new
      end
    end
  end
end
