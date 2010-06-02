# set the applicationname here
set :application, "customer_name"

# ssh user settings. please change to customers
set :user, "user"
set :password, "secret"

# please set domain names
role :app, "78.47.48.250"
role :web, "78.47.48.250"
role :db,  "78.47.48.250", :primary => true

# set the public webserver path
set :deploy_to, "/var/www/#{user}/html/alchemy"

# set the apps repository url
set :repository_url, "http://svn.vondeyen.com/customers/#{application}"

##### DO NOT CHANGE BELOW THIS LINE #########

set :scm, :subversion
set :scm_user, "capistrano"
set :scm_password, "C4p1fy"
set :use_sudo, false
set :port, 12312

set :repository, Proc.new{ "--username #{scm_user} --password #{scm_password} #{repository_url}" }

before "deploy:restart", "deploy:migrate"

after "deploy:setup", "alchemy:create_shared_folders"
after "deploy:symlink", "alchemy:symlink_folders"

namespace :alchemy do

  desc "Creates the uploads and images cache directory in the shared folder"
  task :create_shared_folders, :roles => :app do
    run "mkdir -p #{shared_path}/uploads"
    run "mkdir -p #{shared_path}/uploads/images"
    run "mkdir -p #{shared_path}/uploads/files"
    run "mkdir -p #{shared_path}/cache"
    run "mkdir -p #{shared_path}/cache/wa_images"
  end

  desc "Sets the symlinks for uploads and images cache folder"
  task :symlink_folders, :roles => :app do
    run "rm -rf #{current_path}/public/uploads/*"
    run "ln -nfs #{shared_path}/uploads/images/ #{current_path}/public/uploads/images"
    run "ln -nfs #{shared_path}/uploads/files/ #{current_path}/public/uploads/files"
    run "rm -rf #{current_path}/public/wa_images"
    run "ln -nfs #{shared_path}/cache/wa_images/ #{current_path}/public/wa_images"
  end

  desc "Update washAPP and generates migrations to finally migrate"
  task :update, :roles => :app do
    run "cd #{current_path} && svn update --username #{scm_user} --password #{scm_password} vendor/plugins/alchemy"
    run "cd #{current_path} && RAILS_ENV=production script/generate plugin_migration"
    deploy.migrate
    deploy.restart
  end

  desc "Copies local cache to shared cache folder"
  task :copy_cache, :roles => :app do
    run "mkdir -p #{shared_path}/cache"
    run "mkdir -p #{shared_path}/cache/wa_images"
    run "cp -R #{current_path}/public/wa_images/* #{shared_path}/cache/wa_images/"
    run "rm -rf #{current_path}/public/wa_images"
    run "ln -nfs #{shared_path}/cache/wa_images #{current_path}/public/"
  end

  @datestring = Time.now.strftime("%Y_%m_%d_%H_%M_%S")

  desc "Get all live data (images, files and database) from remote server"
  task :get_all_live_data do
    alchemy.get_db_dump
    alchemy.get_images
    alchemy.get_files
  end

  desc "Get all live data (images, files and database) from remote server and replace the local data with it"
  task :clone_live do
    alchemy.get_all_live_data
    alchemy.import_images
    alchemy.import_files
    alchemy.import_db
  end

  desc "Zip all uploaded images and store them in shared/uploads folder on server"
  task :zip_images do
    run "cd #{deploy_to}/shared/uploads && tar cfz images.tar.gz images/"
  end

  desc "Zip all uploaded files and store them in shared/uploads folder on server"
  task :zip_files do
    run "cd #{deploy_to}/shared/uploads && tar cfz files.tar.gz files/"
  end

  desc "Make database dump and store into backup folder"
  task :dump_db do
    db_settings = database_settings['production']
    run "cd #{deploy_to}/shared && mysqldump -u#{db_settings['username']} -p#{db_settings['password']} -S#{db_settings['socket']} -h#{db_settings['host']} #{db_settings['database']} > dump_#{@datestring}.sql"
  end

  desc "Get images zip from remote server and store it in public/uploads/images.tar.gz"
  task :get_images do
    alchemy.zip_images
    download "#{deploy_to}/shared/uploads/images.tar.gz", "public/uploads/images.tar.gz"
  end

  desc "Get files zip from remote server and store it in public/uploads/files.tar.gz"
  task :get_files do
    alchemy.zip_files
    download "#{deploy_to}/shared/uploads/files.tar.gz", "public/uploads/files.tar.gz"
  end

  desc "Get db dump from remote server and store it in db/<Time>.sql"
  task :get_db_dump do
    alchemy.dump_db
    download "#{deploy_to}/shared/dump_#{@datestring}.sql", "db/dump_#{@datestring}.sql"
  end

  desc "Extracts the images.tar.gz into the uploads/images folder"
  task :import_images do
    `rm -rf public/uploads/images`
    `cd public/uploads/ && tar xzf images.tar.gz`
  end

  desc "Extracts the files.tar.gz into the uploads/files folder"
  task :import_files do
    `rm -rf public/uploads/files`
    `cd public/uploads/ && tar xzf files.tar.gz`
  end

  desc "Imports the database file"
  task :import_db do
    db_settings = database_settings['development']
    `rake db:drop`
    `rake db:create`
    `mysql -uroot #{db_settings['database']} < db/dump_#{@datestring}.sql`
  end
  
  desc "PRIVATE! Release a new alchemy Version. ONLY FOR internal usage!"
  task :release do
    system('svn remove -m "removing for new release" http://svn.vondeyen.com/releases/0.1beta/')
    system('svn copy -m "new release" http://svn.vondeyen.com/alchemy/trunk http://svn.vondeyen.com/alchemy/releases/0.1beta')
  end
  
end

namespace :ferret do
  desc "Start the ferret server"
  task :start, :roles => :app do
    run "cd #{current_path} && script/ferret_server start -eproduction"
  end

  desc "Stop the ferret server"
  task :stop, :roles => :app do
    run "cd #{current_path} && script/ferret_server stop -eproduction"
  end

  desc "Restart the ferret server"
  task :restart, :roles => :app do
    run "cd #{current_path} && script/ferret_server stop -eproduction"
    run "cd #{current_path} && script/ferret_server start -eproduction"
  end
end

namespace :deploy do
  desc "Overwrite for the internal Capistrano deploy:start task."
  task :start, :roles => :app do
    run "echo 'Nothing to start, because mod_passenger is handeling everything. Hooray!'"
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
