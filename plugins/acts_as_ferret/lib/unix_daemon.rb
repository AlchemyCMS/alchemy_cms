################################################################################
module ActsAsFerret
  module Remote

    ################################################################################
    # methods for becoming a daemon on Unix-like operating systems
    module UnixDaemon

      ################################################################################
      def platform_daemon (&block)
        safefork do
          write_pid_file
          trap("TERM") { exit(0) }
          sess_id = Process.setsid
          STDIN.reopen("/dev/null")
          STDOUT.reopen("#{RAILS_ROOT}/log/ferret_server.out", "a")
          STDERR.reopen(STDOUT)
          block.call
        end
      end

      ################################################################################
      # stop the daemon, nicely at first, and then forcefully if necessary
      def stop
        pid = read_pid_file
        raise "ferret_server doesn't appear to be running" unless pid
        $stdout.puts("stopping ferret server...")
        Process.kill("TERM", pid)
        30.times { Process.kill(0, pid); sleep(0.5) }
        $stdout.puts("using kill -9 #{pid}")
        Process.kill(9, pid)
      rescue Errno::ESRCH => e
        $stdout.puts("process #{pid} has stopped")
      ensure
        File.unlink(@cfg.pid_file) if File.exist?(@cfg.pid_file)
      end

      ################################################################################
      def safefork (&block)
        @fork_tries ||= 0
        fork(&block)
      rescue Errno::EWOULDBLOCK
        raise if @fork_tries >= 20
        @fork_tries += 1
        sleep 5
        retry
      end

      #################################################################################
      # create the PID file and install an at_exit handler
      def write_pid_file
        ensure_stopped
        open(@cfg.pid_file, "w") {|f| f << Process.pid << "\n"}
        at_exit { File.unlink(@cfg.pid_file) if read_pid_file == Process.pid }
      end

      #################################################################################
      def read_pid_file
        File.read(@cfg.pid_file).to_i if File.exist?(@cfg.pid_file)
      end

      #################################################################################
      def ensure_stopped
        if pid = read_pid_file
          if process_exists(pid)
            raise "ferret_server may already be running, a pid file exists: #{@cfg.pid_file} and a ferret_server process exists with matching pid #{pid}"
          else
            $stdout.puts("removing stale pid file...")
            File.unlink(@cfg.pid_file) if File.exist?(@cfg.pid_file)
          end
        end
      end

      #################################################################################
      # Check for existence of ferret_server process with PID from pid file
      # checked on ubuntu and OSX only
      def process_exists(pid)
        ps = IO.popen("ps -fp #{pid}", "r")
        process = ps.to_a[1]
        ps.close
        process =~ /ferret_server/
      end

    end
  end
end
