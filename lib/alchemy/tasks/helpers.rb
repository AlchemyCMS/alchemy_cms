module Alchemy
  module Tasks
    module Helpers
      def database_dump_command(adapter)
        database_command(adapter, 'dump')
      end

      def database_import_command(adapter)
        database_command(adapter, 'import')
      end

      def database_config
        raise "Could not find #{database_config_file}!" if !File.exist?(database_config_file)
        @database_config ||= begin
          config_file = YAML.safe_load(ERB.new(File.read(database_config_file)).result, [], [], true)
          config_file.fetch(environment)
        rescue KeyError
            raise "Database configuration for #{environment} not found!"
        end
      end

      private

      def database_command(adapter, action = 'import')
        case adapter.to_s
        when /mysql/
          "#{mysql_command(mysql_command_for(action))} #{database_config['database']}"
        when /postgresql/
          "#{postgres_command(postgres_command_for(action))} #{database_config['database']}"
        else
          raise ArgumentError, "Alchemy only supports #{action}ing MySQL and PostgreSQL databases. #{adapter} is not supported."
        end
      end

      def mysql_command(cmd = 'mysql')
        command = [cmd]
        if database_config['username']
          command << "--user='#{database_config['username']}'"
        end
        if database_config['password']
          command << "--password='#{database_config['password']}'"
        end
        if (host = database_config['host']) && (host != 'localhost')
          command << "--host='#{host}'"
        end
        command.join(' ')
      end

      def postgres_command(cmd = 'psql')
        command = []
        if database_config['password']
          command << "PGPASSWORD='#{database_config['password']}'"
        end
        command << cmd
        if database_config['username']
          command << "--username='#{database_config['username']}'"
        end
        if (host = database_config['host']) && (host != 'localhost')
          command << "--host='#{host}'"
        end
        command.join(' ')
      end

      def mysql_command_for(action)
        action == 'import' ? 'mysql' : 'mysqldump'
      end

      def postgres_command_for(action)
        action == 'import' ? 'psql' : 'pg_dump --clean'
      end

      def database_config_file
        "./config/database.yml"
      end

      def environment
        ENV['RAILS_ENV'] || 'development'
      end
    end
  end
end
