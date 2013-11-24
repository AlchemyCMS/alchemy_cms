module Alchemy
  module Tasks
    module Helpers

      def mysql_credentials
        mysql_credentials = []
        if database_config['username']
          mysql_credentials << "--user='#{database_config['username']}'"
        end
        if database_config['password']
          mysql_credentials << "--password='#{database_config['password']}'"
        end
        if (host = database_config['host']) && (host != 'localhost')
          mysql_credentials << "--host='#{host}'"
        end
        mysql_credentials.join(' ')
      end

      def database_config
        raise "Could not find #{database_config_file}!" if !File.exists?(database_config_file)
        @database_config ||= begin
          config_file = YAML.load_file(database_config_file)
          config_file.fetch(environment)
          rescue KeyError
            raise "Database configuration for #{environment} not found!"
        end
      end

      private

      def database_config_file
        "./config/database.yml"
      end

      def environment
        ENV['RAILS_ENV'] || 'development'
      end

    end
  end
end
