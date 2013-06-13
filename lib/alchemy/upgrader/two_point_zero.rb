module Alchemy
  module Upgrader::TwoPointZero

  private
    
    def strip_alchemy_from_schema_version_table
      database_yml = YAML.load_file(Rails.root.join("config", "database.yml"))
      connection = Mysql2::Client.new(database_yml.fetch(Rails.env.to_s).symbolize_keys)
      connection.query "UPDATE schema_migrations SET `schema_migrations`.`version` = REPLACE(`schema_migrations`.`version`,'-alchemy','')"
    end

  end
end
