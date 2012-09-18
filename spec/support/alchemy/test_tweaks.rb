# Fixes Capybara database connection issues
# Found http://blog.plataformatec.com.br/2011/12/three-tips-to-improve-the-performance-of-your-test-suite/

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# fast truncation of all tables that need truncations (select is 10x faster then truncate)
# http://grosser.it/2012/07/03/rubyactiverecord-fastest-way-to-truncate-test-database/
def truncate_all_tables
  config = ActiveRecord::Base.configurations[::Rails.env]
  connection = ActiveRecord::Base.connection
  connection.disable_referential_integrity do
    connection.tables.each do |table_name|
      next if connection.select_value("SELECT count(*) FROM #{table_name}") == 0
      case config["adapter"]
        when "mysql2", "postgresql"
          connection.execute("TRUNCATE #{table_name}")
        when "sqlite3"
          connection.execute("DELETE FROM #{table_name}")
          connection.execute("DELETE FROM sqlite_sequence where name='#{table_name}'")
      end
    end
    connection.execute("VACUUM") if config["adapter"] == "sqlite3"
  end
end
