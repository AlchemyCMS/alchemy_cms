# frozen_string_literal: true

require "fileutils"

module Alchemy
  class Upgrader::SevenPointThree < Upgrader
    def self.remove_admin_stylesheets
      if File.exist? "vendor/assets/stylesheets/alchemy/admin/all.css"
        log "Removing Alchemy admin stylesheets."
        FileUtils.rm_f "vendor/assets/stylesheets/alchemy/admin/all.css"
      end
    end
  end
end
