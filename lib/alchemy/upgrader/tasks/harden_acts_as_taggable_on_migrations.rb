require 'thor'

module Alchemy::Upgrader::Tasks
  class HardenActsAsTaggableOnMigrations < Thor
    include Thor::Actions

    no_tasks do
      def patch_migrations
        sentinel = /add_column.*/
        aato_file = Dir.glob('db/migrate/*_add_taggings_counter_cache_to_tags.*.rb').first
        if aato_file
          inject_into_file aato_file,
            "\n\n    # inserted by Alchemy CMS upgrader\n    return unless defined?(ActsAsTaggableOn)",
            { after: sentinel, verbose: true }
        end

        sentinel = /def up/
        aato_file = Dir.glob('db/migrate/*_change_collation_for_tag_names.*.rb').first
        if aato_file
          inject_into_file aato_file,
            "\n    # inserted by Alchemy CMS upgrader\n    return unless defined?(ActsAsTaggableOn)\n",
            { after: sentinel, verbose: true }
        end
      end
    end
  end
end
