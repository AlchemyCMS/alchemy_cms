# frozen_string_literal: true

require "thor"

module Alchemy::Upgrader::Tasks
  class HardenGutentagMigrations < Thor
    include Thor::Actions

    no_tasks do
      def patch_migrations
        sentinel = /def up/

        migration_file = Dir.glob("db/migrate/*_gutentag_tables.gutentag.rb").first
        if migration_file
          inject_into_file migration_file,
            "\n    # inserted by Alchemy CMS upgrader\n    return if table_exists?(:gutentag_taggings)\n",
            { after: sentinel, verbose: true }
        end

        migration_file = Dir.glob("db/migrate/*_gutentag_cache_counter.gutentag.rb").first
        if migration_file
          inject_into_file migration_file,
            "\n    # inserted by Alchemy CMS upgrader\n    return if column_exists?(:gutentag_tags, :taggings_count)\n",
            { after: sentinel, verbose: true }
        end
      end
    end
  end
end
