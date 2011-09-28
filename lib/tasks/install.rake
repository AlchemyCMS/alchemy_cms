# encoding: UTF-8
require File.join(File.dirname(__FILE__), '../alchemy/file_utilz.rb')

namespace :alchemy do
  
  desc "Migrates the database, inserts essential data into the database and copies all assets."
  task :prepare do
    Rake::Task['alchemy:migrations:sync'].invoke
    Rake::Task['alchemy:seeder:copy'].invoke
    Rake::Task['alchemy:assets:copy:all'].invoke
  end
  
  namespace 'seeder' do
    desc "Copy a line of code into the seeds.rb file"
    task :copy do
      File.open("./db/seeds.rb", "a") do |f|
        f.puts "\n# Seeding Alchemy data"
        f.puts "Alchemy::Seeder.seed!\n"
      end
    end
  end
  
  namespace 'migrations' do
    desc "Syncs Alchemy migrations into db/migrate"
    task 'sync' do
			system "rsync -ruv #{File.join(File.dirname(__FILE__), '..', '..', 'db', 'migrate')} #{Rails.root}/db"
    end
  end

  namespace 'assets' do
    namespace 'copy' do
      
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
				system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'javascripts', '*')} #{Rails.root.to_s}/public/javascripts/alchemy/"
      end
      
      desc "Copy stylesheets for Alchemy into apps public folder"
      task :stylesheets do
        system "rm -rf #{Rails.root.to_s}/public/stylesheets/alchemy"
				system "mkdir -p #{Rails.root.to_s}/public/stylesheets/alchemy"
				system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'stylesheets', '*')} #{Rails.root.to_s}/public/stylesheets/alchemy/"
      end
      
      desc "Copy images for Alchemy into apps public folder"
      task :images do
				system "rm -rf #{Rails.root.to_s}/public/images/alchemy"
				system "mkdir -p #{Rails.root.to_s}/public/images/alchemy"
				system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'images', '*')} #{Rails.root.to_s}/public/images/alchemy/"
      end
      
    end
  end
  
  namespace :standard_set do
    
    desc "Install Alchemys standard set."
    task :install do
      system("rails g alchemy:scaffold --with_standard_set")
      Rake::Task['alchemy:assets:copy:all'].invoke
    end
    
  end

  namespace :cells do
    
    desc "Creates all cells for all pages"
    task :create => :environment do
      cell_yml = File.join(File.dirname(__FILE__), '..', '..', '..', '..', '..', 'config', 'alchemy', 'cells.yml')
      page_layouts = Alchemy::PageLayout.get_layouts
      if File.exist?(cell_yml) && page_layouts
        cells = YAML.load_file(cell_yml)
        page_layouts.each do |layout|
          unless layout['cells'].blank?
            cells_for_layout = cells.select { |cell| layout['cells'].include? cell['name'] }
            Page.find_all_by_page_layout(layout['name']).each do |page|
              cells_for_layout.each do |cell_for_layout|
                cell = Cell.find_or_initialize_by_name_and_page_id({:name => cell_for_layout['name'], :page_id => page.id})
                cell.elements << page.elements.select { |element| cell_for_layout['elements'].include?(element.name) }
                if cell.new_record?
                  cell.save
                  puts "== Creating cell '#{cell.name}' for page '#{page.name}'"
                else
                  puts "== Skipping! Cell '#{cell.name}' for page '#{page.name}' was already present"
                end
              end
            end
          end
        end
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
