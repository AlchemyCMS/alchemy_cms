module Alchemy
  module Upgrader::TwoPointZero

  private

    def strip_alchemy_from_schema_version_table
      ActiveRecord::Base.connection.execute(
        "UPDATE schema_migrations SET version = REPLACE(version,'-alchemy','')"
      )
    end

  end
end
