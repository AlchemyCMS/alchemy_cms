# This recipe contains Capistrano recipes for handling the uploads, ferret index and picture cache files while deploying your application.
# It also contains a ferret:rebuild_index task to rebuild the index after deploying your application.
require "rails"
require "alchemy/mount_point"

Capistrano::Configuration.instance(:must_exist).load do

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
				run "mkdir -p #{File.join(shared_path, 'cache', Capistrano::CLI.ui.ask("Where is Alchemy CMS mounted at? ('/')"), 'pictures')}"
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
				db_config = ERB.new <<-EOF
production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  pool: 5
  database: #{ Capistrano::CLI.ui.ask("Database name: ") }
  username: #{ Capistrano::CLI.ui.ask("Database username: ") }
  password: #{ Capistrano::CLI.ui.ask("Database password: ") }
  socket: #{ Capistrano::CLI.ui.ask("Database socket: ") }
  host: #{ Capistrano::CLI.ui.ask("Database host: ") }
EOF
				run "mkdir -p #{shared_path}/config"
				put db_config.result, "#{shared_path}/config/database.yml"
			end

			desc "[internal] Symlinks the database.yml file from shared folder into config folder"
			task :symlink, :except => { :no_release => true } do
				run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
			end

		end

		namespace :db do

			desc "Seeds the database with essential data."
			task :seed, :roles => :app do
				run "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env, 'production')} #{rake} alchemy:db:seed"
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
