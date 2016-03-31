require 'thor'

module Alchemy::Upgrader::Tasks
  class ThreePointTwoTask < Thor
    include Thor::Actions

    no_tasks do
      def patch_acts_as_taggable_on_migrations
        sentinel = /def self.up/

        aato_file = Dir.glob('db/migrate/*_acts_as_taggable_on_migration.*.rb').first
        if aato_file
          inject_into_file aato_file,
            "\n    # inserted by Alchemy CMS upgrader\n    return if table_exists?(:tags)\n",
            { after: sentinel, verbose: true }
        end

        aato_file = Dir.glob('db/migrate/*_add_missing_unique_indices.*.rb').first
        if aato_file
          inject_into_file aato_file,
            "\n    # inserted by Alchemy CMS upgrader\n    return if index_exists?(:tags, :name)\n",
            { after: sentinel, verbose: true }
        end
      end

      def inject_seeder
        append_file "./db/seeds.rb", "Alchemy::Seeder.seed!\n"
      end
    end
  end
end
