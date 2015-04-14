# This recipe contains Capistrano recipes for handling the uploads
# and picture cache files while deploying your application.

require 'fileutils'
require 'alchemy/tasks/helpers'
require 'alchemy/mount_point'

include Alchemy::Tasks::Helpers

::Capistrano::Configuration.instance(:must_exist).load do

  after "deploy:setup", "alchemy:shared_folders:create"
  after "deploy:finalize_update", "alchemy:shared_folders:symlink"
  before "deploy:start", "deploy:seed"

  namespace :alchemy do

    namespace :shared_folders do

      # This task creates the shared folders for uploads, assets and picture cache while setting up your server.
      desc "Creates the uploads and picture cache directory in the shared folder. Called after deploy:setup"
      task :create, :roles => :app do
        run "mkdir -p #{shared_path}/uploads/pictures"
        run "mkdir -p #{shared_path}/uploads/attachments"
        run "mkdir -p #{shared_picture_cache_path}"
        run "mkdir -p #{shared_path}/cache"
      end

      # This task symlinks the uploads, picture and general cache folder to the new release.
      desc "Sets the symlinks for uploads and picture cache folder. Called after deploy:finalize_update"
      task :symlink, :roles => :app do
        run "rm -rf #{release_path}/uploads"
        run "ln -nfs #{shared_path}/uploads #{release_path}/"
        run "mkdir -p #{public_path_with_mountpoint}"
        run "ln -nfs #{shared_picture_cache_path} #{public_path_with_mountpoint('pictures')}"
        run "ln -nfs #{shared_path}/cache #{release_path}/tmp/cache"
      end

      def shared_picture_cache_path
        @shared_picture_cache_path ||= begin
          File.join(shared_path, 'cache', Alchemy::MountPoint.get, 'pictures')
        end
      end

      def public_path_with_mountpoint(suffix = '')
        @release_picture_cache_path ||= begin
          File.join(release_path, 'public', Alchemy::MountPoint.get, suffix)
        end
      end

    end

    desc "Upgrades production database to current Alchemy CMS version"
    task :upgrade do
      run "cd #{current_path} && #{rake} RAILS_ENV=#{fetch(:rails_env, 'production')} alchemy:upgrade"
    end

    namespace :database_yml do

      desc "Creates the database.yml file"
      task :create do
        environment      = Capistrano::CLI.ui.ask("\nPlease enter the environment (Default: #{fetch(:rails_env, 'production')})")
        environment      = fetch(:rails_env, 'production') if environment.empty?
        db_adapter       = Capistrano::CLI.ui.ask("Please enter database adapter (Options: mysql2, or postgresql. Default mysql2): ")
        db_adapter       = db_adapter.empty? ? 'mysql2' : db_adapter.gsub(/\Amysql\z/, 'mysql2')
        db_name          = Capistrano::CLI.ui.ask("Please enter database name: ")
        db_username      = Capistrano::CLI.ui.ask("Please enter database username: ")
        db_password      = Capistrano::CLI.password_prompt("Please enter database password: ")
        default_db_host  = db_adapter == 'mysql2' ? 'localhost' : '127.0.0.1'
        db_host          = Capistrano::CLI.ui.ask("Please enter database host (Default: #{default_db_host}): ")
        db_host          = db_host.empty? ? default_db_host : db_host
        db_config        = ERB.new <<-EOF
#{environment}:
  adapter: #{ db_adapter }
  encoding: utf8
  reconnect: false
  pool: 5
  database: #{ db_name }
  username: #{ db_username }
  password: #{ db_password }
  host: #{ db_host }
EOF
        run "mkdir -p #{shared_path}/config"
        put db_config.result, "#{shared_path}/config/database.yml"
      end

      desc "[internal] Symlinks the database.yml file from shared folder into config folder"
      task :symlink, :except => {:no_release => true} do
        run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      end

    end

    namespace :db do

      desc "Dumps the database into 'db/dumps' on the server."
      task :dump, :roles => :db do
        timestamp = Time.now.strftime('%Y-%m-%d-%H-%M')
        run "cd #{current_path} && mkdir -p db/dumps && #{rake} RAILS_ENV=#{fetch(:rails_env, 'production')} DUMP_FILENAME=db/dumps/#{timestamp}.sql alchemy:db:dump"
      end

    end

    namespace :import do

      desc "Imports all data (Pictures, attachments and the database) into your local development machine."
      task :all, :roles => [:app, :db] do
        pictures
        attachments
        database
      end

      desc "Imports the server database into your local development machine."
      task :database, :roles => [:db], :only => {:primary => true} do
        require 'spinner'
        server = find_servers_for_task(current_task).first
        spinner = Spinner.new
        print "\n"
        spinner.task("Importing the database. Please wait...") do
          system db_import_cmd(server)
        end
        spinner.spin!
      end

      desc "Imports attachments into your local machine using rsync."
      task :attachments, :roles => [:app] do
        get_files :attachments
      end

      desc "Imports pictures into your local machine using rsync."
      task :pictures, :roles => [:app] do
        get_files :pictures
      end

      def get_files(type)
        FileUtils.mkdir_p "./uploads"
        server = find_servers_for_task(current_task).first
        if server
          system "rsync --progress -rue 'ssh -p #{fetch(:port, 22)}' #{user}@#{server}:#{shared_path}/uploads/#{type} ./uploads/"
        else
          raise "No server found"
        end
      end

      def db_import_cmd(server)
        dump_cmd = "cd #{current_path} && #{rake} RAILS_ENV=#{fetch(:rails_env, 'production')} alchemy:db:dump"
        sql_stream = "ssh -p #{fetch(:port, 22)} #{user}@#{server} '#{dump_cmd}'"
        "#{sql_stream} | #{database_import_command(database_config['adapter'])} 1>/dev/null 2>&1"
      end
    end

    namespace :export do
      desc "Sends all data (Pictures, attachments and the database) to your remote machine."
      task :all, :roles => [:app, :db] do
        pictures
        attachments
        database
      end

      desc "Imports the server database into your local development machine."
      task :database, :roles => [:db], :only => {:primary => true} do
        if Capistrano::CLI.ui.agree('WARNING: This task will override your remote database. Do you want me to make a backup? (y/n)')
          backup_database
          export_database
        else
          if Capistrano::CLI.ui.agree('Are you sure? (y/n)')
            export_database
          else
            backup_database
            export_database
          end
        end
      end

      desc "Sends attachments to your remote machine using rsync."
      task :attachments, :roles => [:app] do
        send_files :attachments
      end

      desc "Sends pictures to your remote machine using rsync."
      task :pictures, :roles => [:app] do
        send_files :pictures
      end

      # Makes a backup of the remote database and stores it in db/ folder
      def backup_database
        Capistrano::CLI.ui.say('Backing up database')
        timestamp = Time.now.strftime('%Y-%m-%d-%H-%M')
        run "cd #{current_path} && #{rake} RAILS_ENV=#{fetch(:rails_env, 'production')} alchemy:db:dump DUMP_FILENAME=db/dump-#{timestamp}.sql"
      end

      # Sends the database via ssh to the server
      def export_database
        require 'spinner'
        server = find_servers_for_task(current_task).first
        spinner = Spinner.new
        print "\n"
        spinner.task("Exporting the database. Please wait...") do
          system db_export_cmd(server)
        end
        spinner.spin!
      end

      # The actual export command that sends the data
      def db_export_cmd(server)
        import_cmd = "cd #{current_path} && #{rake} RAILS_ENV=#{fetch(:rails_env, 'production')} alchemy:db:import"
        ssh_cmd = "ssh -p #{fetch(:port, 22)} #{user}@#{server} '#{import_cmd}'"
        "#{database_dump_command(database_config['adapter'])} | #{ssh_cmd}"
      end

      # Sends files of given type via rsync to server
      def send_files(type)
        FileUtils.mkdir_p "./uploads/#{type}"
        server = find_servers_for_task(current_task).first
        if server
          system "rsync --progress -rue 'ssh -p #{fetch(:port, 22)}' uploads/#{type} #{user}@#{server}:#{shared_path}/uploads/"
        else
          raise "No server found"
        end
      end
    end

  end

end
