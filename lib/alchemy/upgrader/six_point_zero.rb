# frozen_string_literal: true

require_relative "tasks/add_page_versions"
require_relative "tasks/ingredients_migrator"

module Alchemy
  class Upgrader::SixPointZero < Upgrader
    class << self
      def create_public_page_versions
        desc "Create public page versions for pages"
        Alchemy::Upgrader::Tasks::AddPageVersions.new.create_public_page_versions
      end

      def create_ingredients
        desc "Create ingredients for elements with ingredients defined"
        Alchemy::Upgrader::Tasks::IngredientsMigrator.new.create_ingredients
        log "Done.", :success
      end
    end
  end
end
