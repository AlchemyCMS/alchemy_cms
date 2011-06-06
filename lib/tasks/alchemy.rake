# encoding: UTF-8

require 'alchemy/migrator'
require 'alchemy/seeder'

namespace :db do

  namespace :migrate do
    
    desc "Runs the Alchemy database migrations"
    task :alchemy => :environment do
      Alchemy::Migrator.create_schema_migrations_table if Alchemy::Migrator.schema_migrations_table_missing?
      Alchemy::Migrator.run_migration(Alchemy::Migrator.available_versions.max)
    end
    
  end
  
  namespace :seed do
    
    desc 'Seeds the database for Alchemy'
    task :alchemy => :environment do
      Alchemy::Seeder.seed!
    end
    
  end

end

namespace :alchemy do
  
  desc "Migrates the database, inserts essential data into the database and copies all assets."
  task :prepare do
    Rake::Task['db:migrate:alchemy'].invoke
    Rake::Task['db:seed:alchemy'].invoke
    Rake::Task['alchemy:assets:copy:all'].invoke
  end
  
  namespace :assets do
    namespace :copy do
      
      desc "Copy all assets for Alchemy into apps public folder"
      task :all do
        Rake::Task['alchemy:assets:copy:javascripts'].invoke
        Rake::Task['alchemy:assets:copy:stylesheets'].invoke
        Rake::Task['alchemy:assets:copy:images'].invoke
      end
      
      desc "Copy javascripts for Alchemy into apps public folder"
      task :javascripts do
        system "rm -rf #{Rails.root.to_s}/public/javascripts/alchemy"
        system "mkdir -p #{Rails.root.to_s}/public/javascripts/alchemy"
        system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', '..', 'assets', 'javascripts', '*')} #{Rails.root.to_s}/public/javascripts/alchemy/"
      end
      
      desc "Copy stylesheets for Alchemy into apps public folder"
      task :stylesheets do
        system "rm -rf #{Rails.root.to_s}/public/stylesheets/alchemy"
        system "mkdir -p #{Rails.root.to_s}/public/stylesheets/alchemy"
        system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', '..', 'assets', 'stylesheets', '*')} #{Rails.root.to_s}/public/stylesheets/alchemy/"
      end
      
      desc "Copy images for Alchemy into apps public folder"
      task :images do
        system "rm -rf #{Rails.root.to_s}/public/images/alchemy"
        system "mkdir -p #{Rails.root.to_s}/public/images/alchemy"
        system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', '..', 'assets', 'images', '*')} #{Rails.root.to_s}/public/images/alchemy/"
      end
      
    end
  end
  
  namespace :standard_set do
    
    desc "Runs all tasks and generators to install Alchemys standard set."
    task :install do
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate:alchemy'].invoke
      Rake::Task['db:seed:alchemy'].invoke
      system("rails g alchemy:scaffold --with_standard_set")
      Rake::Task['alchemy:assets:copy:all'].invoke
    end
    
  end
  
end

namespace :ferret do
  
  desc "Updates the ferret index for the application."
  task :rebuild_index => :environment do
    puts "Rebuilding Ferret Index for EssenceText"
    Alchemy::EssenceText.rebuild_index
    puts "Rebuilding Ferret Index for EssenceRichtext"
    Alchemy::EssenceRichtext.rebuild_index
    puts "Completed Ferret Index Rebuild"
  end
  
end
