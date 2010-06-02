module Ddb
  module Userstamp
    module MigrationHelper
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def userstamps(include_deleted_by = false)
          column(Ddb::Userstamp.compatibility_mode ? :created_by : :creator_id, :integer)
          column(Ddb::Userstamp.compatibility_mode ? :updated_by : :updater_id, :integer)
          column(Ddb::Userstamp.compatibility_mode ? :deleted_by : :deleter_id, :integer) if include_deleted_by
        end
        
        def remove_userstamps(include_deleted_by = false)
          @base.remove_column(@table_name, Ddb::Userstamp.compatibility_mode ? :created_by : :creator_id, :integer)
          @base.remove_column(@table_name, Ddb::Userstamp.compatibility_mode ? :updated_by : :updater_id, :integer)
          @base.remove_column(@table_name, Ddb::Userstamp.compatibility_mode ? :deleted_by : :deleter_id, :integer) if include_deleted_by
        end
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, Ddb::Userstamp::MigrationHelper)
ActiveRecord::ConnectionAdapters::Table.send(:include, Ddb::Userstamp::MigrationHelper)
