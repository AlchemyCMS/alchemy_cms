# frozen_string_literal: true

require_relative "tasks/harden_gutentag_migrations"

module Alchemy
  class Upgrader::FivePointZero < Upgrader
    class << self
      def install_gutentag_migrations
        desc "Install Gutentag migrations"
        `bundle exec rake gutentag:install:migrations`
        Alchemy::Upgrader::Tasks::HardenGutentagMigrations.new.patch_migrations
        `bundle exec rake db:migrate`
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
    end
  end
end
