# frozen_string_literal: true

require "thor"

module Alchemy
  class Upgrader::SevenPointZero < Upgrader
    include Thor::Base
    include Thor::Actions

    class << self
      def update_admin_entrypoint
        if File.exist? "app/javascript/packs/alchemy/admin.js"
          FileUtils.mv "app/javascript/packs/alchemy/admin.js", "app/javascript/alchemy_admin.js"
        else
          log "Skipping. No alchemy/admin entrypoint found. Maybe already migrated from Webpacker?", :info
        end
        if Dir.exist?("app/javascript/packs/alchemy") && Dir.empty?("app/javascript/packs/alchemy")
          FileUtils.rm_r "app/javascript/packs/alchemy"
        end
        if File.exist? "config/importmap.rb"
          # We want the bundled package if using importmaps
          task.gsub_file "app/javascript/alchemy_admin.js", 'import "@alchemy_cms/admin"', 'import "@alchemy_cms/dist/admin"'
        end
        if task.ask("Do you want to remove webpacker now? (y/N)", default: "N") == "y"
          task.run "yarn remove @rails/webpacker webpack webpack-cli webpack-dev-server"
          FileUtils.rm_r "app/javascript/packs"
          FileUtils.rm_r "config/webpack"
          FileUtils.rm "config/webpacker.yml"
          FileUtils.rm "bin/webpack"
          FileUtils.rm "bin/webpack-dev-server"
        end
        if task.ask("Do you want to add jsbundling-rails now? (Y/n)", default: "Y") == "Y"
          task.run "bundle add jsbundling-rails"
          task.run "bin/rails javascript:install:esbuild"
        end
      end

      private

      def task
        @_task || new
      end
    end
  end
end
