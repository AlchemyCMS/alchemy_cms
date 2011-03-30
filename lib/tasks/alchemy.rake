require 'yaml'

namespace :db do
  namespace :migrate do
    
    desc "Runs the Alchemy database migrations"
    task :alchemy => :environment do
      Alchemy::Migrator.create_schema_migrations_table if Alchemy::Migrator.schema_migrations_table_missing?
      Alchemy::Migrator.run_migration(Alchemy::Migrator.available_versions.max)
    end
    
    desc 'For engines coming from Rails version < 2.0 or for those previously updated to work with Sven Fuch\'s fork of engines, you need to upgrade the schema info table'
    task :upgrade_schema_table => :environment do
      svens_fork_table_name = 'plugin_schema_migrations'
      engines_schema_table_name = 'plugin_schema_info'
      
      # Check if app was previously using Sven's fork
      if ActiveRecord::Base.connection.table_exists?(svens_fork_table_name)
        old_sm_table = svens_fork_table_name
      else
        old_sm_table = ActiveRecord::Migrator.proper_table_name(engines_schema_table_name)
      end
      
      unless ActiveRecord::Base.connection.table_exists?(old_sm_table)
        abort "Cannot find old migration table - assuming nothing needs to be done"
      end
      
      # There are two forms of the engines schema info - pre-fix_plugin_migrations and post
      # We need to figure this out before we continue.
      
      results = ActiveRecord::Base.connection.select_rows(
        "SELECT version, plugin_name FROM #{old_sm_table}"
      ).uniq
      
      def insert_new_version(plugin_name, version)
        version_string = "#{version}-#{plugin_name}"
        new_sm_table = ActiveRecord::Migrator.schema_migrations_table_name
        
        # Check if the row already exists for some reason - maybe run this task more than once.
        return if ActiveRecord::Base.connection.select_rows("SELECT * FROM #{new_sm_table} WHERE version = #{version_string.dump.gsub("\"", "'")}").size > 0
        
        puts "Inserting new version #{version} for plugin #{plugin_name}.."
        ActiveRecord::Base.connection.insert("INSERT INTO #{new_sm_table} (version) VALUES (#{version_string.dump.gsub("\"", "'")})")
      end
      
      # We need to figure out if they already used "fix_plugin_migrations"
      versions = {}
      results.each do |r|
        versions[r[1]] ||= []
        versions[r[1]] << r[0].to_i
      end
      
      if versions.values.find{ |v| v.size > 1 } == nil
        puts "Fixing migration info"
        # We only have one listed migration per plugin - this is pre-fix_plugin_migrations,
        # so we build all versions required. In this case, all migrations should 
        versions.each do |plugin_name, version|
          version = version[0] # There is only one version
          
          # We have to make an assumption that numeric migrations won't get this long..
          # I'm not sure if there is a better assumption, it should work in all
          # current cases.. (touch wood..)
          if version.to_s.size < "YYYYMMDDHHMMSS".size
            # Insert version records for each migration
            (1..version).each do |v|
             insert_new_version(plugin_name, v)
            end
          else
            # If the plugin is new-format "YYYYMMDDHHMMSS", we just copy it across... 
            # The case in which this occurs is very rare..
            insert_new_version(plugin_name, version)
          end
        end
      else
        puts "Moving migration info"
        # We have multiple migrations listed per plugin - thus we can assume they have
        # already applied fix_plugin_migrations - we just copy it across verbatim
        versions.each do |plugin_name, version|
          version.each { |v| insert_new_version(plugin_name, v) }
        end
      end
      
      puts "Migration info successfully migrated - removing old schema info table"
      ActiveRecord::Base.connection.drop_table(old_sm_table)
    end
    
  end
  
end

namespace 'alchemy' do
  
  desc 'Turns everything in Alchemy. Voodooo'
  task 'run_upgrade' do
    Rake::Task['alchemy:upgrades:cleanup'].invoke
    Rake::Task['alchemy:upgrades:environment_file'].invoke
    Rake::Task['alchemy:upgrades:write_rake_task'].invoke
    Rake::Task['alchemy:upgrades:generate_migration'].invoke
    Rake::Task['alchemy:app_structure:create:all'].invoke
    #Rake::Task['alchemy:upgrades:svn:rename'].invoke
    #Rake::Task['alchemy:upgrades:svn:commit'].invoke
  end
  
  namespace 'migrations' do
    desc "Syncs Alchemy migrations into db/migrate"
    task 'sync' do
      system "rsync -ruv #{File.join(File.dirname(__FILE__), '..', '..', 'db', 'migrate')} #{Rails.root}/db"
    end
  end
  
  namespace 'app_structure' do
    namespace 'create' do
    
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
        if File.directory? "#{Rails.root}/config/alchemy"
          puts "Task Aborted: Config folder already exists: #{Rails.root}/config/alchemy"
        else
          system "mkdir -p #{Rails.root}/config/alchemy"
          system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', '*')} #{RAILS_ROOT}/config/alchemy/"
          puts "Created folder with configuration files:\n#{Rails.root}/config/alchemy"
        end
      end
      
      desc "Create alchemy´s basic locales for individualising."
      task "locales" do
        system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', 'config', 'locales', '*')} #{RAILS_ROOT}/config/locales/"
        puts "Created basic locales:\n#{Rails.root}/app/config/locales"
      end
      
      desc "Create basic layout file for pages_controller."
      task "layout" do
        system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', 'app', 'views', 'layouts', 'pages.html.erb')} #{RAILS_ROOT}/app/views/layouts/"
        puts "Created layout file for your individual layout rendered by pages_controller:\n#{Rails.root}/app/views/page_layouts"
      end
      
      desc "Creates alchemy´s page_layout folder."
      task "page_layouts" do
        if File.directory? "#{Rails.root}/app/views/page_layouts"
          puts "Task Aborted: page_layouts folder already exists: #{Rails.root}/app/views/page_layouts"
        else
          system "mkdir -p #{Rails.root}/app/views/page_layouts"
          puts "Created folder for your individual page_layout files rendered inside the layout:\n#{Rails.root}/app/views/page_layouts"
        end
      end
      
      desc "Creates alchemy´s elements folder."
      task "elements" do
        if File.directory? "#{Rails.root}/app/views/elements"
          puts "Task Aborted: elements folder already exists: #{Rails.root}/app/views/elements"
        else
          puts "Created folder for your individual elements:\n#{Rails.root}/app/views/elements"
          system "mkdir -p #{Rails.root}/app/views/elements"
        end
      end
      
    end    
  end
  
  namespace 'assets' do
    namespace 'copy' do
      
      desc "Copy all assets for Alchemy into apps public folder"
      task "all" do
        Rake::Task['alchemy:assets:copy:javascripts'].invoke
        Rake::Task['alchemy:assets:copy:stylesheets'].invoke
        Rake::Task['alchemy:assets:copy:images'].invoke
      end
      
      desc "Copy javascripts for Alchemy into apps public folder"
      task "javascripts" do
        system "rm -rf #{Rails.root}/public/javascripts/alchemy"
        system "mkdir -p #{Rails.root}/public/javascripts/alchemy"
        system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'javascripts', '*')} #{RAILS_ROOT}/public/javascripts/alchemy/"
      end
      
      desc "Copy stylesheets for Alchemy into apps public folder"
      task "stylesheets" do
        system "rm -rf #{Rails.root}/public/stylesheets/alchemy"
        system "mkdir -p #{Rails.root}/public/stylesheets/alchemy"
        system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'stylesheets', '*')} #{RAILS_ROOT}/public/stylesheets/alchemy/"
      end
      
      desc "Copy images for Alchemy into apps public folder"
      task "images" do
        system "rm -rf #{Rails.root}/public/images/alchemy"
        system "mkdir -p #{Rails.root}/public/images/alchemy"
        system "rsync -r #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'images', '*')} #{RAILS_ROOT}/public/images/alchemy/"
      end
      
    end
  end
  
  namespace 'upgrades' do
    
    desc "Removing unused files and directories"
    task "cleanup" do
      system('rm -rf vendor/plugins/webmate')
      system('rm -rf public/plugin_assets/webmate')
      system('rm config/initializers/fast_gettext.rb config/initializers/cache_storage.rb config/initializers/session_store.rb')
    end
    
    desc 'Writes a rake file into lib/tasks to make all the Alchemy plugins tasks available'
    task 'write_rake_task' do
      s = <<EOF
# Make all the Alchemy plugins tasks available
Dir.glob(File.dirname(__FILE__) + "/../../vendor/plugins/alchemy/plugins/**/tasks/*.rake").each do |rake_file|
  import rake_file
end
EOF
      File.open('lib/tasks/alchemy_plugins_tasks.rake', 'w') { |f| f.write(s)}
    end
    
    desc "Generates migration for upgrading the database."
    task "generate_migration" do
      system('script/generate migration upgrade_db_for_alchemy')
      migration_file = Dir.glob("db/migrate/*_upgrade_db_for_alchemy.rb").first
      s = <<EOF
class UpgradeDbForAlchemy < ActiveRecord::Migration
  def self.up
    
    # Removing unused tables
    drop_table :wa_atom_checkboxes
    drop_table :wa_atom_formtags
    drop_table :wa_atom_galleries
    drop_table :wa_atom_gallery_pictures
    drop_table :wa_atom_molecule_selectors
    drop_table :wa_atom_resetbuttons
    drop_table :wa_atom_selectboxes
    drop_table :wa_atom_submitbuttons
    drop_table :wa_atom_text_bigs
    drop_table :wa_atom_textareas
    drop_table :wa_atom_textfields
    drop_table :wa_gallery_images
    drop_table :wa_atom_sitemaps
    
    # renaming tables
    rename_table :wa_pages, :pages
    rename_table :wa_molecules, :elements
    rename_table :wa_atoms, :contents
    rename_table :wa_users, :users
    rename_table :wa_images, :pictures
    rename_table :wa_files, :attachments
    rename_table :wa_foldeds, :folded_pages
    rename_table :wa_molecules_wa_pages, :elements_pages
    rename_table :wa_atom_texts, :essence_texts
    rename_table :wa_atom_rtfs, :essence_richtexts
    rename_table :wa_atom_pictures, :essence_pictures
    rename_table :wa_atom_files, :essence_files
    rename_table :wa_atom_htmls, :essence_htmls
    rename_table :wa_atom_flashvideos, :essence_videos
    rename_table :wa_atom_flashes, :essence_flashes
    rename_table :wa_atom_dates, :essence_dates
    rename_table :wa_atom_audios, :essence_audios
    
    # renaming tables rows
    rename_column :elements, :wa_page_id, :page_id
    rename_column :elements_pages, :wa_molecule_id, :element_id
    rename_column :elements_pages, :wa_page_id, :page_id
    rename_column :folded_pages, :wa_user_id, :user_id
    rename_column :folded_pages, :wa_page_id, :page_id
    rename_column :contents, :wa_molecule_id, :element_id
    rename_column :contents, :atom_id, :essence_id
    rename_column :contents, :atom_type, :essence_type
    rename_column :essence_pictures, :wa_image_id, :picture_id
    rename_column :essence_files, :wa_file_id, :attachment_id
    rename_column :essence_videos, :wa_file_id, :attachment_id
    rename_column :essence_audios, :wa_file_id, :attachment_id
    rename_column :essence_flashes, :wa_file_id, :attachment_id
    rename_column :essence_texts, :content, :body
    rename_column :essence_richtexts, :content, :body
    rename_column :essence_richtexts, :stripped_content, :stripped_body
    rename_column :pages, :systempage, :layoutpage
    
    # Changing WaAtoms to Essences
    execute("UPDATE contents SET essence_type = REPLACE(essence_type, 'WaAtom', 'Essence')")
    execute("UPDATE contents SET essence_type = REPLACE(essence_type, 'EssenceRtf', 'EssenceRichtext')")
    execute("UPDATE contents SET essence_type = REPLACE(essence_type, 'EssenceFlashvideo', 'EssenceVideo')")
    
    # Renaming old userstamp columns to new userstamp columns
    rename_column :essence_htmls, :content, :source
    rename_column :pages, :created_by, :creator_id
    rename_column :pages, :updated_by, :updater_id
    
    # Adding userstamps to tables
    add_column :essence_audios, :creator_id, :integer
    add_column :essence_audios, :updater_id, :integer
    add_column :attachments, :creator_id, :integer
    add_column :attachments, :updater_id, :integer
    add_column :contents, :creator_id, :integer
    add_column :contents, :updater_id, :integer
    add_column :essence_dates, :creator_id, :integer
    add_column :essence_dates, :updater_id, :integer
    add_column :essence_files, :creator_id, :integer
    add_column :essence_files, :updater_id, :integer
    add_column :essence_flashes, :creator_id, :integer
    add_column :essence_flashes, :updater_id, :integer
    add_column :essence_htmls, :creator_id, :integer
    add_column :essence_htmls, :updater_id, :integer
    add_column :essence_pictures, :creator_id, :integer
    add_column :essence_pictures, :updater_id, :integer
    add_column :essence_richtexts, :creator_id, :integer
    add_column :essence_richtexts, :updater_id, :integer
    add_column :essence_texts, :creator_id, :integer
    add_column :essence_texts, :updater_id, :integer
    add_column :essence_videos, :creator_id, :integer
    add_column :essence_videos, :updater_id, :integer
    add_column :pictures, :creator_id, :integer
    add_column :pictures, :updater_id, :integer
    add_column :elements, :creator_id, :integer
    add_column :elements, :updater_id, :integer
    add_column :users, :creator_id, :integer
    add_column :users, :updater_id, :integer
    
    # Adding columns
    add_column :users, :gender, :string
    
    execute("INSERT INTO schema_migrations SET version = '20100607143125-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607144254-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607145256-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607145719-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607150611-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607150812-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607153647-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607161345-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607162339-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607193638-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607193646-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100607193653-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100609111653-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100609111809-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100609111821-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100609111837-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100616150753-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100709163925-alchemy'")
    execute("INSERT INTO schema_migrations SET version = '20100812085225-alchemy'")
    
  end

  def self.down
    raise IrreversibleMigration
  end
end
EOF
      File.open(migration_file, 'w') { |f| f.write(s)}
    end
    
    desc "Updates the config/environment.rb file"
    task "environment_file" do
      s = <<EOF
RAILS_GEM_VERSION = '2.3.10' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'acts_as_ferret', :version => '0.4.8.2'
  config.gem 'authlogic', :version => '>=2.1.2'
  config.gem 'awesome_nested_set', :version => '>=1.4.3'
  config.gem 'declarative_authorization', :version => '>=0.4.1'
  config.gem "fleximage", :version => ">=1.0.4"
  config.gem 'fast_gettext', :version => '>=0.4.8'
  config.gem 'gettext_i18n_rails', :version => '0.2.3'
  config.gem 'gettext', :lib => false, :version => '>=1.9.3'
  config.gem 'rmagick', :lib => "RMagick2", :version => '>=2.13.1'
  config.gem 'jk-ferret', :version => '>=0.11.8.2', :lib => 'ferret'
  config.gem 'will_paginate', :version => '2.3.15'
  config.gem 'mimetype-fu', :version => '>=0.1.2', :lib => 'mimetype_fu'
  config.autoload_paths += %W( vendor/plugins/alchemy/app/sweepers )
  config.autoload_paths += %W( vendor/plugins/alchemy/app/middleware )
  config.i18n.load_path += Dir[Rails.root.join('vendor/plugins/alchemy/config', 'locales', '*.{rb,yml}')]
  config.time_zone = 'Berlin'
  config.i18n.default_locale = :de
end
EOF
      File.open('config/environment.rb', 'w') { |f| f.write(s)}
    end
    
    namespace :svn do
      
      desc "Renaming files and folders for svn repository"
      task "rename" do
        system('svn rename config/webmate config/alchemy')
        system('svn rename config/alchemy/molecules.yml config/alchemy/elements.yml')
        system('svn rename app/views/wa_molecules app/views/elements')
        system('svn rename app/views/layouts/wa_pages.html.erb app/views/layouts/pages.html.erb')
        system('svn remove config/initializers/fast_gettext.rb config/initializers/cache_storage.rb')
      end

      desc "Commits everything into you svn repository"
      task "commit" do
        system("svn mkdir uploads")
        system("svn propset svn:ignore '*' uploads/")
        system("svn add lib/tasks/alchemy_plugins_tasks.rake")
        system("svn add db/migrate/*")
        system("svn commit -m 'upgraded to alchemy'")
      end
      
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
  task :rebuild_index => [ :environment ] do | t |
    puts "Rebuilding Ferret Index for EssenceText"
    EssenceText.rebuild_index
    puts "Rebuilding Ferret Index for EssenceRichtext"
    EssenceRichtext.rebuild_index
    puts "Completed Ferret Index Rebuild"
  end
end
