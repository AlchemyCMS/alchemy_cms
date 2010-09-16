# The Alchemy::Migrator class contains the logic to run migrations for Alchemy
#
# To migrate Alchemy, you can simple call the run_migration method (Alchemy::Migrator#run_migration)
# with the version number that alchemy should be at. The Alchemy's migrations
# will then be used to migrate up (or down) to the given version.
#
# Taken from the Engines plugin
#
module Alchemy
  class Migrator < ActiveRecord::Migrator

    class << self
      # Runs the migrations, up (or down) to the version given
      def run_migration(version)
        return if current_version == version
        migrate(File.join(File.dirname(__FILE__), '..', '..', 'db/migrate'), version)
      end
    
      def current_version
        ::ActiveRecord::Base.connection.select_values(
          "SELECT version FROM #{schema_migrations_table_name}"
        ).delete_if{ |v| v.match(/-alchemy/) == nil }.map(&:to_i).max || 0
      end
    
      def available_versions
        files = Dir.glob(File.join(File.dirname(__FILE__), '..', '..', 'db/migrate/*'))
        files.map { |f| f.gsub(/[^-0-9]/, '').to_i }
      end
    
      def schema_already_converted?
        db_versions = ActiveRecord::Base.connection.select_values(
          "SELECT version FROM #{schema_migrations_table_name}"
        ).delete_if{ |v| v.match(/-alchemy/) == nil }
        db_versions.length == available_versions.length
      end
    
    end
  
    def migrated
      sm_table = self.class.schema_migrations_table_name
      ::ActiveRecord::Base.connection.select_values(
        "SELECT version FROM #{sm_table}"
      ).delete_if{ |v| v.match(/-alchemy/) == nil }.map(&:to_i).sort
    end
  
    def record_version_state_after_migrating(version)
      super(version.to_s + "-alchemy")
    end
  
  end
end
