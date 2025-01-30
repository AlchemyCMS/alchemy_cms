# frozen_string_literal: true

require "fileutils"
require "thor"

module Alchemy
  class Upgrader::SevenPointFour < Upgrader
    include Thor::Base
    include Thor::Actions

    class << self
      def update_custom_css_config
        if File.exist? "app/assets/config/manifest.js"
          log "Removing alchemy/admin/custom.css from assets config file."
          task.gsub_file "app/assets/config/manifest.js", %r{//= link alchemy/admin/custom.css\n}, ""
        end
      end

      private

      def task
        @_task || new
      end
    end
  end
end
