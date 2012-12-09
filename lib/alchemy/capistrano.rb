# This recipe contains Capistrano recipes for handling the uploads, ferret index and picture cache files while deploying your application.
# It also contains a ferret:rebuild_index task to rebuild the index after deploying your application.
require 'fileutils'

::Capistrano::Configuration.instance(:must_exist).load do

  after "deploy:setup", "alchemy:shared_folders:create"
  after "deploy:finalize_update", "alchemy:shared_folders:symlink"
  before "deploy:start", "alchemy:db:seed"

  namespace :alchemy do

    namespace :shared_folders do

      # This task creates the shared folders for uploads, picture cache and ferret index while setting up your server.
      # Call after deploy:setup like +after "deploy:setup", "alchemy:create_shared_folders"+ in your +deploy.rb+.
      desc "Creates the uploads and picture cache directory in the shared folder. Call after deploy:setup"
      task :create, :roles => :app do
        run "mkdir -p #{shared_path}/index"
        run "mkdir -p #{shared_path}/uploads/pictures"
        run "mkdir -p #{shared_path}/uploads/attachments"
        run "mkdir -p #{File.join(shared_path, 'cache', Capistrano::CLI.ui.ask("\nWhere is Alchemy CMS mounted at? ('/'): "), 'pictures')}"
      end

      # This task sets the symlinks for uploads, picture cache and ferret index folder.
      # Call after deploy:symlink like +after "deploy:symlink", "alchemy:symlink_folders"+ in your +deploy.rb+.
      desc "Sets the symlinks for uploads, picture cache and ferret index folder. Call after deploy:symlink"
      task :symlink, :roles => :app do
        run "rm -rf #{release_path}/uploads"
        run "ln -nfs #{shared_path}/uploads #{release_path}/"
        run "ln -nfs #{shared_path}/cache/* #{release_path}/public/"
        run "rm -rf #{release_path}/index"
        run "ln -nfs #{shared_path}/index #{release_path}/"
      end

    end

    desc "Upgrades production database to current Alchemy CMS version"
    task :upgrade do
      run "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env, 'production')} #{rake} alchemy:upgrade"
    end

    namespace :database_yml do

      desc "Creates the database.yml file"
      task :create do
        db_adapter       = Capistrano::CLI.ui.ask("\nPlease enter database adapter (Options: mysql2, or postgresql. Default mysql2): ")
        db_adapter       = db_adapter.empty? ? 'mysql2' : db_adapter.gsub(/^mysql$/, 'mysql2')
        db_name          = Capistrano::CLI.ui.ask("Please enter database name: ")
        db_username      = Capistrano::CLI.ui.ask("Please enter database username: ")
        db_password      = Capistrano::CLI.ui.ask("Please enter database password: ")
        default_db_host  = db_adapter == 'mysql2' ? 'localhost' : '127.0.0.1'
        db_host          = Capistrano::CLI.ui.ask("Please enter database host (Default: #{default_db_host}): ")
        db_host          = db_host.empty? ? default_db_host : db_host
        db_config        = ERB.new <<-EOF
production:
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

      desc "Seeds the database with essential data."
      task :seed, :roles => :db do
        run "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env, 'production')} #{rake} alchemy:db:seed"
      end

      desc "Dumps the database into 'db/dumps'"
      task :dump, :roles => :db do
        run "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env, 'production')} #{rake} alchemy:db:dump"
      end

    end

    namespace :import do

      desc "Imports all data (Pictures, attachments and the database) into your local development machine."
      task :all, :roles => [:app, :db] do
        pictures
        attachments
        database
      end

      desc "Imports the database into your local development machine."
      task :database, :roles => [:db] do
        filename = "#{fetch(:application, 'dump')}-#{timestamp}.sql"
        run "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env, 'production')} DUMP_FILENAME=#{filename} #{rake} alchemy:db:dump"
        FileUtils.mkdir_p "./db/dumps"
        download "#{current_path}/db/dumps/#{filename}", "db/dumps/#{filename}"
        run_locally "mysql -u#{database_config['username']}#{database_config['password'] ? ' -p"' + database_config['password'] + '"' : nil} #{database_config['database']} < ./db/dumps/#{filename}"
      end

      desc "Imports attachments into your local machine."
      task :attachments, :roles => [:app] do
        filename = zip_files('attachments')
        FileUtils.mkdir_p "./uploads"
        download "#{shared_path}/uploads/#{filename}", "./uploads/#{filename}"
        unzip_files('attachments', filename)
      end

      desc "Imports pictures into your local machine."
      task :pictures, :roles => [:app] do
        filename = zip_files('pictures')
        FileUtils.mkdir_p "./uploads"
        download "#{shared_path}/uploads/#{filename}", "./uploads/#{filename}"
        unzip_files('pictures', filename)
      end

      def zip_files(type)
        filename = "#{type}-#{timestamp}.tar.gz"
        run "cd #{shared_path}/uploads && tar cvfz #{filename} #{type}/"
        filename
      end

      def timestamp
        timestamp ||= Time.now.strftime('%Y-%m-%d-%H-%M')
      end

      def unzip_files(type, filename)
        FileUtils.rm_rf "./uploads/#{type}"
        run_locally "cd ./uploads && tar xvzf #{filename}"
      end

      def database_config
        raise "database.yml not found!" if !File.exists?("./config/database.yml")
        YAML.load_file("./config/database.yml")['development']
      end

    end

  end

  namespace :ferret do

    # This task rebuilds the ferret index for the EssenceText and EssenceRichtext Models.
    # Call it before deploy:restart like +before "deploy:restart", "alchemy:rebuild_index"+ in your +deploy.rb+.
    # It uses the +alchemy:rebuild_index+ rake task found in +vendor/plugins/alchemy/lib/tasks+.
    desc "Rebuild the ferret index. Call before deploy:restart"
    task :rebuild_index, :roles => :app do
      run "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env, 'production')} #{rake} ferret:rebuild_index"
    end

  end

end
