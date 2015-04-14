require 'thor'

class Alchemy::Upgrader::ThreePointTwoTask < Thor
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

module Alchemy
  module Upgrader::ThreePointTwo
    private

    def upgrade_acts_as_taggable_on_migrations
      desc 'Installs acts_as_taggable_on migrations.'
      # We can't invoke this rake task, because Rails will use wrong engine names otherwise
      `bundle exec rake railties:install:migrations`
      Alchemy::Upgrader::ThreePointTwoTask.new.patch_acts_as_taggable_on_migrations
      Rake::Task["db:migrate"].invoke
    end

    def inject_seeder
      desc 'Add Alchemy seeder to `db/seeds.rb` file.'
      Alchemy::Upgrader::ThreePointTwoTask.new.inject_seeder
    end
  end
end
