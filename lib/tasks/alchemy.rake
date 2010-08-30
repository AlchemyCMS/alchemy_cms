namespace :db do
  namespace :migrate do
    description = "Migrate the database through scripts in vendor/plugins/alchemy/lib/db/migrate"
    description << "and update db/schema.rb by invoking db:schema:dump."
    description << "Target specific version with VERSION=x. Turn off output with VERBOSE=false."

    desc description
    task :alchemy => :environment do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate(File.join(File.dirname(__FILE__), "../../db/migrate/"), ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
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
    Rake::Task['db:migrate'].invoke
    Rake::Task['alchemy:upgrades:rename_files_and_folders'].invoke
    Rake::Task['alchemy:upgrades:add_locales'].invoke
    Rake::Task['alchemy:upgrades:svn_commit'].invoke
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
      task "all" do
        Rake::Task['alchemy:assets:copy:javascripts'].invoke
        Rake::Task['alchemy:assets:copy:stylesheets'].invoke
        Rake::Task['alchemy:assets:copy:images'].invoke
      end
      
      desc "Copy javascripts for Alchemy into apps public folder"
      task "javascripts" do
        system "mkdir -p #{Rails.root}/public/javascripts/alchemy"
        system "rsync -r --delete #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'javascripts', '*')} #{RAILS_ROOT}/public/javascripts/alchemy/"
      end
      
      desc "Copy stylesheets for Alchemy into apps public folder"
      task "stylesheets" do
        system "mkdir -p #{Rails.root}/public/stylesheets/alchemy"
        system "rsync -r --delete #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'stylesheets', '*')} #{RAILS_ROOT}/public/stylesheets/alchemy/"
      end
      
      desc "Copy images for Alchemy into apps public folder"
      task "images" do
        system "mkdir -p #{Rails.root}/public/images/alchemy"
        system "rsync -r --delete #{File.join(File.dirname(__FILE__), '..', '..', 'assets', 'images', '*')} #{RAILS_ROOT}/public/images/alchemy/"
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
    ActiveRecord::Base.connection.update_sql("UPDATE contents set essence_type = REPLACE(essence_type, 'WaAtom', 'Essence')")
    ActiveRecord::Base.connection.update_sql("UPDATE contents set essence_type = REPLACE(essence_type, 'EssenceRtf', 'EssenceRichtext')")
    ActiveRecord::Base.connection.update_sql("UPDATE contents set essence_type = REPLACE(essence_type, 'EssenceFlashvideo', 'EssenceVideo')")
    
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
  end

  def self.down
    remove_column :users, :gender
    remove_column :essence_audios, :updater_id
    remove_column :essence_audios, :creator_id
    remove_column :attachments, :updater_id
    remove_column :attachments, :creator_id
    rename_column :users, :updater_id, :updated_by
    rename_column :users, :creator_id, :created_by
    rename_column :pages, :updater_id, :updated_by
    rename_column :pages, :creator_id, :created_by
    rename_column :pictures, :updater_id, :updated_by
    rename_column :pictures, :creator_id, :created_by
    rename_column :essence_videos, :updater_id, :updated_by
    rename_column :essence_videos, :creator_id, :created_by
    rename_column :essence_texts, :updater_id, :updated_by
    rename_column :essence_texts, :creator_id, :created_by
    rename_column :essence_richtexts, :updater_id, :updated_by
    rename_column :essence_richtexts, :creator_id, :created_by
    rename_column :essence_pictures, :updater_id, :updated_by
    rename_column :essence_pictures, :creator_id, :created_by
    rename_column :essence_htmls, :source, :content
    rename_column :essence_htmls, :updater_id, :updated_by
    rename_column :essence_htmls, :creator_id, :created_by
    rename_column :essence_flashes, :updater_id, :updated_by
    rename_column :essence_flashes, :creator_id, :created_by
    rename_column :essence_files, :updater_id, :updated_by
    rename_column :essence_files, :creator_id, :created_by
    rename_column :essence_dates, :updater_id, :updated_by
    rename_column :essence_dates, :creator_id, :created_by
    rename_column :elements, :updater_id, :updated_by
    rename_column :elements, :creator_id, :created_by
    rename_column :contents, :updater_id, :updated_by
    rename_column :contents, :creator_id, :created_by
    ActiveRecord::Base.connection.update_sql("UPDATE contents set essence_type = REPLACE(essence_type, 'EssenceVideo', 'EssenceFlashvideo')")
    ActiveRecord::Base.connection.update_sql("UPDATE contents set essence_type = REPLACE(essence_type, 'EssenceRichtext', 'EssenceRtf')")
    ActiveRecord::Base.connection.update_sql("UPDATE contents set essence_type = REPLACE(essence_type, 'Essence', 'WaAtom')")
    rename_column :pages, :layoutpage, :systempage
    rename_column :essence_richtexts, :stripped_body, :stripped_content
    rename_column :essence_richtexts, :body, :content
    rename_column :essence_texts, :body, :content
    rename_column :essence_flashes, :attachment_id, :wa_file_id
    rename_column :essence_audios, :attachment_id, :wa_file_id
    rename_column :essence_videos, :attachment_id, :wa_file_id
    rename_column :essence_files, :attachment_id, :wa_file_id
    rename_column :essence_pictures, :picture_id, :wa_image_id
    rename_column :contents, :essence_type, :atom_type
    rename_column :contents, :essence_id, :atom_id
    rename_column :contents, :element_id, :wa_molecule_id
    rename_column :folded_pages, :page_id, :wa_page_id
    rename_column :folded_pages, :user_id, :wa_user_id
    rename_column :elements_pages, :page_id, :wa_page_id
    rename_column :elements_pages, :element_id, :wa_molecule_id
    rename_column :elements, :page_id, :wa_page_id
    rename_table :essence_audios, :wa_atom_audios
    rename_table :essence_dates, :wa_atom_dates
    rename_table :essence_flashes, :wa_atom_flashes
    rename_table :essence_videos, :wa_atom_flashvideos
    rename_table :essence_htmls, :wa_atom_htmls
    rename_table :essence_files, :wa_atom_files
    rename_table :essence_pictures, :wa_atom_pictures
    rename_table :essence_richtexts, :wa_atom_rtfs
    rename_table :essence_texts, :wa_atom_texts
    rename_table :elements_pages, :wa_molecules_wa_pages
    rename_table :folded_pages, :wa_foldeds
    rename_table :attachments, :wa_files
    rename_table :pictures, :wa_images
    rename_table :users, :wa_users
    rename_table :contents, :wa_atoms
    rename_table :elements, :wa_molecules
    rename_table :pages, :wa_pages
    create_table "wa_gallery_images", :force => true do |t|
      t.integer "wa_image_id"
    end
    create_table "wa_atom_textfields", :force => true do |t|
      t.boolean  "validate",   :default => false
      t.string   "name"
      t.boolean  "hidden",     :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "wa_atom_textareas", :force => true do |t|
      t.boolean  "validate",   :default => false
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "wa_atom_text_bigs", :force => true do |t|
      t.string "content"
    end
    create_table "wa_atom_submitbuttons", :force => true do |t|
      t.string   "label"
      t.boolean  "close_form", :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "wa_atom_selectboxes", :force => true do |t|
      t.boolean  "validate",   :default => false
      t.string   "name"
      t.boolean  "multiple",   :default => false
      t.text     "options"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "wa_atom_resetbuttons", :force => true do |t|
      t.string   "label"
      t.boolean  "close_form", :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "wa_atom_molecule_selectors", :force => true do |t|
      t.integer "wa_molecule_id"
    end
    create_table "wa_atom_gallery_pictures", :force => true do |t|
      t.integer "wa_image_id"
      t.string  "caption",     :default => ""
    end
    create_table "wa_atom_galleries", :force => true do |t|
      t.string  "title"
      t.integer "wa_molecule_id"
      t.integer "wa_gallery_image_id"
    end
    create_table "wa_atom_formtags", :force => true do |t|
      t.string   "action"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "wa_atom_checkboxes", :force => true do |t|
      t.boolean  "validate",   :default => false
      t.string   "name"
      t.boolean  "checked",    :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "wa_atom_sitemaps", :force => true do |t|
      t.string  "content"
    end
  end
end
EOF
      File.open(migration_file, 'w') { |f| f.write(s)}
    end
    
    desc "Updates the config/environment.rb file"
    task "environment_file" do
      s = <<EOF
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/alchemy/plugins/engines/boot')

Rails::Initializer.run do |config|
  config.gem 'ferret'
  config.gem "grosser-fast_gettext", :version => '>=0.4.8', :lib => 'fast_gettext', :source => "http://gems.github.com"
  config.gem "gettext", :lib => false, :version => '>=1.9.3'
  config.gem "rmagick", :lib => "RMagick2"
  config.gem 'mime-types', :lib => "mime/types"

  config.plugin_paths << File.join(File.dirname(__FILE__), '../vendor/plugins/alchemy/plugins')
  config.plugins = [ :declarative_authorization, :all, :alchemy ]
  config.load_paths += %W( \#{RAILS_ROOT}/vendor/plugins/alchemy/app/sweepers )
  config.load_paths += %W( \#{RAILS_ROOT}/vendor/plugins/alchemy/app/middleware )
  config.i18n.load_path += Dir[Rails.root.join('vendor/plugins/alchemy/config', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :de
  config.active_record.default_timezone = :berlin
end
EOF
      File.open('config/environment.rb', 'w') { |f| f.write(s)}
    end
    
    desc "Renaming files and folders for svn repository"
    task "rename_files_and_folders" do
      system('svn rename config/webmate config/alchemy')
      system('svn rename config/alchemy/molecules.yml config/alchemy/elements.yml')
      system('svn rename app/views/wa_molecules app/views/elements')
      system('svn rename app/views/layouts/wa_pages.html.erb app/views/layouts/pages.html.erb')
      system('svn remove config/initializers/fast_gettext.rb config/initializers/cache_storage.rb config/initializers/session_store.rb')
    end
    
    desc "Commits everything into you svn repository"
    task "svn_commit" do
      system("svn mkdir uploads")
      system("svn propset svn:ignore '*' uploads/")
      system("svn add lib/tasks/alchemy_plugins_tasks.rake")
      system("svn add db/migrate/*")
      system("svn commit -m 'upgraded to alchemy'")
    end
    
    desc "Adding config/locale folder if not exists and place de.yml and en.yml file in it."
    task "add_locales" do
      de = <<EOF
de:
  content_names:
    headline: 'Überschrift'
    text: 'Text'
    date: 'Datum'
    body: 'Inhalt'
EOF
      en = <<EOF
en:
  content_names:
    headline: 'Headline'
    text: 'Text'
    date: 'Date'
    body: 'Content'
EOF
      Dir.mkdir('config/locales') if Dir.glob('config/locales').empty?
      File.open('config/locales/de.yml', 'w') { |f| f.write(de) }
      File.open('config/locales/en.yml', 'w') { |f| f.write(en) }
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
