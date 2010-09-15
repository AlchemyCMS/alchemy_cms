# This recipe contains Capistrano recipes for handling the uploads, ferret index and picture cache files while deploying your application.
# It also contains a ferret:rebuild_index task to rebuild the index after deploying your application.

namespace :alchemy do
  
  namespace :shared_folders do
    
    # This task creates the shared folders for uploads, picture cache and ferret index while setting up your server.
    # Call after deploy:setup like +after "deploy:setup", "alchemy:create_shared_folders"+ in your +deploy.rb+.
    desc "Creates the uploads and picture cache directory in the shared folder. Call after deploy:setup"
    task :create, :roles => :app do
      run "mkdir -p #{shared_path}/uploads"
      run "mkdir -p #{shared_path}/index"
      run "mkdir -p #{shared_path}/uploads/pictures"
      run "mkdir -p #{shared_path}/uploads/attachments"
      run "mkdir -p #{shared_path}/cache"
      run "mkdir -p #{shared_path}/cache/pictures"
    end
    
    # This task sets the symlinks for uploads, picture cache and ferret index folder.
    # Call after deploy:symlink like +after "deploy:symlink", "alchemy:symlink_folders"+ in your +deploy.rb+.
    desc "Sets the symlinks for uploads, picture cache and ferret index folder. Call after deploy:symlink"
    task :symlink, :roles => :app do
      run "rm -rf #{current_path}/public/uploads/*"
      run "ln -nfs #{shared_path}/uploads/pictures/ #{current_path}/uploads/pictures"
      run "ln -nfs #{shared_path}/uploads/attachments/ #{current_path}/uploads/attachments"
      run "rm -rf #{current_path}/public/pictures"
      run "ln -nfs #{shared_path}/cache/pictures/ #{current_path}/public/pictures"
      run "rm -rf #{current_path}/index"
      run "ln -nfs #{shared_path}/index/ #{current_path}/index"
    end
    
  end
  
  namespace :assets do
    
    desc "Copies all assets from Alchemy plugin folder to public folder"
    task :copy do
      run "cd #{current_path} && RAILS_ENV=production rake alchemy:assets:copy:all"
    end
    
  end
  
  namespace :db do
    
    desc "Migrate Alchemys database schema"
    task :migrate, :roles => :app, :except => { :no_release => true } do
      run "cd #{current_path} && RAILS_ENV=production rake db:migrate:alchemy"
    end
    
  end
  
end

namespace :ferret do
  
  # This task rebuilds the ferret index for the EssenceText and EssenceRichtext Models.
  # Call it before deploy:restart like +before "deploy:restart", "alchemy:rebuild_index"+ in your +deploy.rb+.
  # It uses the +alchemy:rebuild_index+ rake task found in +vendor/plugins/alchemy/lib/tasks+.
  desc "Rebuild the ferret index. Call before deploy:restart"
  task :rebuild_index, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production rake ferret:rebuild_index"
  end
  
end
