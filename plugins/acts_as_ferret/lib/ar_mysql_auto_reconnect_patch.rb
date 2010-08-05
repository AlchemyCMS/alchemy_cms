# Source: http://pastie.caboo.se/154842
#
# in /etc/my.cnf on the MySQL server, you can set the interactive-timeout parameter,
# for example, 12 hours = 28800 sec
# interactive-timeout=28800

# in ActiveRecord, setting the verification_timeout to something less than
# the interactive-timeout parameter; 14400 sec = 6 hours
ActiveRecord::Base.verification_timeout = 14400
ActiveRecord::Base.establish_connection

# Below is a monkey patch for keeping ActiveRecord connections alive.
# http://www.sparecycles.org/2007/7/2/saying-goodbye-to-lost-connections-in-rails

module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter
      def execute(sql, name = nil) #:nodoc:
        reconnect_lost_connections = true
        begin
          log(sql, name) { @connection.query(sql) }
        rescue ActiveRecord::StatementInvalid => exception
          if reconnect_lost_connections and exception.message =~ /(Lost connection to MySQL server during query
|MySQL server has gone away)/
            reconnect_lost_connections = false
            reconnect!
            retry
          elsif exception.message.split(":").first =~ /Packets out of order/
            raise ActiveRecord::StatementInvalid, "'Packets out of order' error was received from the database.
 Please update your mysql bindings (gem install mysql) and read http://dev.mysql.com/doc/mysql/en/password-hash
ing.html for more information.  If you're on Windows, use the Instant Rails installer to get the updated mysql 
bindings." 
          else
            raise
          end
        end
      end
    end
  end
end

