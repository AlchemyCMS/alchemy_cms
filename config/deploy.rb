# set the applicationname here
set :application, "alchemy"

# ssh user settings. please change to customers
set :user, "web6"
set :password, "3KH7zUjU"
ssh_options[:port] = 12312

set :database_user, "#{user}"
set :database_password, "m0fwts5m"
set :database_name, "usr_#{user}_6"
set :database_host, "localhost"
set :database_socket, "/var/run/mysqld/mysqld.sock"

# please set domain names
role :app, "vondeyen.com"
role :web, "vondeyen.com"
role :db,  "vondeyen.com", :primary => true

# set the public webserver path
set :deploy_to, "/var/www/#{user}/html/alchemy"

# set the apps repository url
set :repository_url, "http://svn.vondeyen.com/#{application}/trunk"

##### DO NOT CHANGE BELOW THIS LINE #########

set :scm, :subversion
set :scm_user, "capistrano"
set :scm_password, "C4p1fy"
set :use_sudo, false

set :repository, Proc.new{ "--username #{scm_user} --password #{scm_password} #{repository_url}" }

before "deploy:restart", "deploy:migrate"

after "deploy:setup", "alchemy:create_shared_folders"
after "deploy:symlink", "alchemy:create_database_yml"
after "deploy:symlink", "alchemy:symlink_folders"

namespace :alchemy do

  desc "Creates the uploads and pictures cache directory in the shared folder"
  task :create_shared_folders, :roles => :app do
    run "mkdir -p #{shared_path}/uploads/pictures"
    run "mkdir -p #{shared_path}/uploads/attachments"
    run "mkdir -p #{shared_path}/cache/pictures"
  end
  
  desc "Creates the database.yml file for server database"
  task :create_database_yml, :roles => :app do
    db_config = ERB.new <<-EOF
    production:
      adapter: mysql
      encoding: utf8
      database: #{database_name}
      username: #{database_user}
      password: #{database_password}
      host: #{database_host}
      socket: #{database_socket}
    EOF
    run "mkdir -p #{shared_path}/config" 
    put db_config.result, "#{shared_path}/config/database.yml"
  end
  
  desc "Sets the symlinks for uploads and pictures cache folder"
  task :symlink_folders, :roles => :app do
    run "rm -rf #{current_path}/uploads/*"
    run "ln -nfs #{shared_path}/uploads/pictures/ #{current_path}/uploads/pictures"
    run "ln -nfs #{shared_path}/uploads/attachments/ #{current_path}/uploads/attachments"
    run "rm -rf #{current_path}/public/pictures"
    run "ln -nfs #{shared_path}/cache/pictures/ #{current_path}/public/pictures"
    run "ln -nfs #{shared_path}/config/database.yml #{current_path}/config/database.yml"
  end

  desc "Update Alchemy and generates migrations to finally migrate"
  task :update, :roles => :app do
    run "cd #{current_path} && svn update --username #{scm_user} --password #{scm_password} vendor/plugins/alchemy"
    run "cd #{current_path} && RAILS_ENV=production script/generate plugin_migration"
    deploy.migrate
    deploy.restart
  end

  desc "Copies local cache to shared cache folder"
  task :copy_cache, :roles => :app do
    run "mkdir -p #{shared_path}/cache"
    run "mkdir -p #{shared_path}/cache/pictures"
    run "cp -R #{current_path}/public/pictures/* #{shared_path}/cache/pictures/"
    run "rm -rf #{current_path}/public/pictures"
    run "ln -nfs #{shared_path}/cache/pictures #{current_path}/public/"
  end

  @datestring = Time.now.strftime("%Y_%m_%d_%H_%M_%S")

  desc "Get all live data (pictures, attachments and database) from remote server"
  task :get_all_live_data do
    alchemy.get_db_dump
    alchemy.get_pictures
    alchemy.get_attachments
  end

  desc "Get all live data (pictures, attachments and database) from remote server and replace the local data with it"
  task :clone_live do
    alchemy.get_all_live_data
    alchemy.import_pictures
    alchemy.import_attachments
    alchemy.import_db
  end

  desc "Zip all uploaded pictures and store them in shared/uploads folder on server"
  task :zip_pictures do
    run "cd #{deploy_to}/shared/uploads && tar cfz pictures.tar.gz pictures/"
  end

  desc "Zip all uploaded attachments and store them in shared/uploads folder on server"
  task :zip_attachments do
    run "cd #{deploy_to}/shared/uploads && tar cfz attachments.tar.gz attachments/"
  end

  desc "Make database dump and store into backup folder"
  task :dump_db do
    db_settings = database_settings['production']
    run "cd #{deploy_to}/shared && mysqldump -u#{db_settings['username']} -p#{db_settings['password']} -S#{db_settings['socket']} -h#{db_settings['host']} #{db_settings['database']} > dump_#{@datestring}.sql"
  end

  desc "Get pictures zip from remote server and store it in uploads/pictures.tar.gz"
  task :get_pictures do
    alchemy.zip_pictures
    download "#{deploy_to}/shared/uploads/pictures.tar.gz", "uploads/pictures.tar.gz"
  end

  desc "Get attachments zip from remote server and store it in uploads/attachments.tar.gz"
  task :get_attachments do
    alchemy.zip_attachments
    download "#{deploy_to}/shared/uploads/attachments.tar.gz", "uploads/attachments.tar.gz"
  end

  desc "Get db dump from remote server and store it in db/<Time>.sql"
  task :get_db_dump do
    alchemy.dump_db
    download "#{deploy_to}/shared/dump_#{@datestring}.sql", "db/dump_#{@datestring}.sql"
  end

  desc "Extracts the pictures.tar.gz into the uploads/pictures folder"
  task :import_pictures do
    `rm -rf uploads/pictures`
    `cd uploads/ && tar xzf pictures.tar.gz`
  end

  desc "Extracts the attachments.tar.gz into the uploads/attachments folder"
  task :import_attachments do
    `rm -rf uploads/attachments`
    `cd uploads/ && tar xzf attachments.tar.gz`
  end

  desc "Imports the database file"
  task :import_db do
    db_settings = database_settings['development']
    `rake db:drop`
    `rake db:create`
    `mysql -uroot #{db_settings['database']} < db/dump_#{@datestring}.sql`
  end
  
  desc "PRIVATE! Release a new Alchemy Version. ONLY FOR internal usage!"
  task :release do
    system('svn remove -m "removing for new release" http://svn.vondeyen.com/alchemy/releases/1.2')
    system('svn copy -m "new release" http://svn.vondeyen.com/alchemy/trunk http://svn.vondeyen.com/alchemy/releases/1.2')
  end
  
end

namespace :deploy do
  desc "Overwrite for the internal Capistrano deploy:start task."
  task :start, :roles => :app do
    run "echo 'Nothing to start'"
  end

  desc "Restart the server"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

def database_settings
  if File.exists? "config/database.yml"
    settings = YAML.load_file "config/database.yml"
  else
    raise "Database File not Found!"
  end
  settings
end
