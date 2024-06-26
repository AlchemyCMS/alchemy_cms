# frozen_string_literal: true

require "thor"

module Alchemy
  class Upgrader::SevenPointZero < Upgrader
    include Thor::Base
    include Thor::Actions

    class << self
      def remove_admin_entrypoint
        FileUtils.rm_rf "app/assets/builds/alchemy_admin.*"
        FileUtils.rm_rf "app/javascript/packs/alchemy/admin.js"
        FileUtils.rm_rf "app/javascript/packs/alchemy_admin.js"
        FileUtils.rm_rf "app/javascript/packs/alchemy"
        FileUtils.rm_rf "app/javascript/packs/alchemy"
        task.run "yarn remove @alchemy_cms/admin"
        if task.ask("Do you want to remove webpacker as well? (y/N)", default: "N") == "y"
          task.run "bundle remove webpacker"
          task.run "yarn remove @rails/webpacker webpack webpack-cli webpack-dev-server"
          FileUtils.rm_rf "app/javascript/packs"
          FileUtils.rm_rf "config/webpack"
          FileUtils.rm_f "config/webpacker.yml"
          FileUtils.rm_f "bin/webpack"
          FileUtils.rm_f "bin/webpack-dev-server"
        end
        if File.exist? "vendor/assets/stylesheets/alchemy/admin/all.css"
          FileUtils.mv "vendor/assets/stylesheets/alchemy/admin/all.css", "vendor/assets/stylesheets/alchemy/admin/all.scss"
        end
        task.append_file "vendor/assets/stylesheets/alchemy/admin/all.scss", "@use \"alchemy/admin\";\n"
        task.run "bin/rails dartsass:install"
      end

      private

      def task
        @_task || new
      end
    end
  end
end
