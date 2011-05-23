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
  
  namespace :app_structure do
    namespace :create do
    
      desc "Creates all necessary folders and files needed for creating your own pagelayouts and elements for your website"
      task "all" do
        Rake::Task['alchemy:app_structure:create:config'].invoke
        Rake::Task['alchemy:app_structure:create:locales'].invoke
        Rake::Task['alchemy:app_structure:create:layout'].invoke
        Rake::Task['alchemy:app_structure:create:page_layouts'].invoke
        Rake::Task['alchemy:app_structure:create:elements'].invoke
      end
      
      desc "Creates alchemy´s configuration folder including its necessary files."
      task "config" do
        if File.directory? "#{Rails.root.to_s}/config/alchemy"
          puts "Task Aborted: Config folder already exists: #{Rails.root.to_s}/config/alchemy"
        else
          system "mkdir -p #{Rails.root.to_s}/config/alchemy"
          system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', '..', 'config', 'alchemy', '*')} #{Rails.root.to_s}/config/alchemy/"
          puts "Created folder with configuration files:\n#{Rails.root.to_s}/config/alchemy"
        end
      end
      
      desc "Create alchemy´s basic locales for individualising."
      task "locales" do
        system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', '..', 'config', 'locales', '*')} #{Rails.root.to_s}/config/locales/"
        puts "Created basic locales:\n#{Rails.root.to_s}/app/config/locales"
      end
      
      desc "Create basic layout file for pages_controller."
      task "layout" do
        system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', '..', 'app', 'views', 'layouts', 'pages.html.erb')} #{Rails.root.to_s}/app/views/layouts/"
        puts "Created layout file for your individual layout rendered by pages_controller:\n#{Rails.root.to_s}/app/views/page_layouts"
      end
      
      desc "Creates alchemy´s page_layout folder."
      task "page_layouts" do
        if File.directory? "#{Rails.root.to_s}/app/views/page_layouts"
          puts "Task Aborted: page_layouts folder already exists: #{Rails.root.to_s}/app/views/page_layouts"
        else
          system "mkdir -p #{Rails.root.to_s}/app/views/page_layouts"
          puts "Created folder for your individual page_layout files rendered inside the layout:\n#{Rails.root.to_s}/app/views/page_layouts"
        end
      end
      
      desc "Creates alchemy´s elements folder."
      task "elements" do
        if File.directory? "#{Rails.root.to_s}/app/views/elements"
          puts "Task Aborted: elements folder already exists: #{Rails.root.to_s}/app/views/elements"
        else
          puts "Created folder for your individual elements:\n#{Rails.root.to_s}/app/views/elements"
          system "mkdir -p #{Rails.root.to_s}/app/views/elements"
        end
      end
      
    end
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
