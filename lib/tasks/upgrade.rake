namespace :alchemy do
  namespace :legacy do

    desc "Upgrades your database to Alchemy 2.0"
    task :upgrade do
      Rake::Task['alchemy:legacy:generate_migration'].invoke
      Rake::Task['alchemy:migrations:sync'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['alchemy:legacy:convert_page_layouts'].invoke
      Rake::Task['alchemy:legacy:elements'].invoke
      Rake::Task['alchemy:legacy:convert_views'].invoke
      Alchemy::Seeder.seed!
      Rake::Task['alchemy:legacy:create_languages'].invoke
      Rake::Task['alchemy:legacy:assign_languages_to_layout_pages'].invoke
      Rake::Task['alchemy:legacy:copy_config'].invoke
    end

    desc "Generates a migration file for migrate the database schema from legacy versions to Alchemy."
    task :generate_migration do
      last_migration = Dir.glob('db/migrate/*.rb').sort.last
      if last_migration
        last_migration_number = last_migration.gsub(/db\/migrate\//, '').to_i
      end
      system('rails g migration upgrade_database_to_alchemy')
      migration_file = Dir.glob("db/migrate/*_upgrade_database_to_alchemy.rb").last
      raise "Migration file not found" if migration_file.nil?
      # We have to rename the migration file into an older one,
      # because the pending alchemy migrations have to run after wards.
      if last_migration_number
        new_name = migration_file.gsub(/[0-9]+/, "%03d" % (last_migration_number + 1))
        FileUtils.mv(migration_file, new_name)
      end
      s = <<EOF
class UpgradeDatabaseToAlchemy < ActiveRecord::Migration

  def self.up

    # Remove unused tables
    drop_table_if_exist :wa_atom_checkboxes
    drop_table_if_exist :wa_atom_formtags
    drop_table_if_exist :wa_atom_galleries
    drop_table_if_exist :wa_atom_gallery_pictures
    drop_table_if_exist :wa_atom_molecule_selectors
    drop_table_if_exist :wa_atom_resetbuttons
    drop_table_if_exist :wa_atom_selectboxes
    drop_table_if_exist :wa_atom_submitbuttons
    drop_table_if_exist :wa_atom_text_bigs
    drop_table_if_exist :wa_atom_textareas
    drop_table_if_exist :wa_atom_textfields
    drop_table_if_exist :wa_gallery_images
    drop_table_if_exist :wa_atom_sitemaps
    drop_table_if_exist :plugin_schema_info
    drop_table_if_exist :right_groups
    drop_table_if_exist :right_groups_rights
    drop_table_if_exist :right_groups_roles
    drop_table_if_exist :rights
    drop_table_if_exist :roles
    drop_table_if_exist :roles_users

    # Removes indexes
    remove_index_if_exist :wa_atoms, [:wa_molecule_id, :position]
    remove_index_if_exist :wa_molecules, [:wa_page_id, :position]
    remove_index_if_exist :wa_pages, [:parent_id, :lft]

    # Rename tables
    rename_table_if_exist :wa_pages, :pages
    rename_table_if_exist :wa_molecules, :elements
    rename_table_if_exist :wa_atoms, :contents
    rename_table_if_exist :wa_users, :users
    rename_table_if_exist :wa_images, :pictures
    rename_table_if_exist :wa_files, :attachments
    rename_table_if_exist :wa_foldeds, :folded_pages
    rename_table_if_exist :wa_molecules_wa_pages, :elements_pages
    rename_table_if_exist :wa_atom_texts, :essence_texts
    rename_table_if_exist :wa_atom_rtfs, :essence_richtexts
    rename_table_if_exist :wa_atom_pictures, :essence_pictures
    rename_table_if_exist :wa_atom_files, :essence_files
    rename_table_if_exist :wa_atom_htmls, :essence_htmls
    rename_table_if_exist :wa_atom_flashvideos, :essence_videos
    rename_table_if_exist :wa_atom_flashes, :essence_flashes
    rename_table_if_exist :wa_atom_dates, :essence_dates
    rename_table_if_exist :wa_atom_audios, :essence_audios

    # Rename columns
    rename_column_if_exist :contents, :wa_molecule_id, :element_id
    rename_column_if_exist :contents, :atom_id, :essence_id
    rename_column_if_exist :contents, :atom_type, :essence_type
    rename_column_if_exist :elements, :wa_page_id, :page_id
    rename_column_if_exist :elements_pages, :wa_molecule_id, :element_id
    rename_column_if_exist :elements_pages, :wa_page_id, :page_id
    rename_column_if_exist :folded_pages, :wa_user_id, :user_id
    rename_column_if_exist :folded_pages, :wa_page_id, :page_id
    rename_column_if_exist :essence_audios, :wa_file_id, :attachment_id
    rename_column_if_exist :essence_files, :wa_file_id, :attachment_id
    rename_column_if_exist :essence_flashes, :wa_file_id, :attachment_id
    rename_column_if_exist :essence_htmls, :content, :source
    rename_column_if_exist :essence_pictures, :wa_image_id, :picture_id
    rename_column_if_exist :essence_richtexts, :content, :body
    rename_column_if_exist :essence_richtexts, :stripped_content, :stripped_body
    rename_column_if_exist :essence_texts, :content, :body
    rename_column_if_exist :essence_videos, :wa_file_id, :attachment_id
    rename_column_if_exist :pages, :systempage, :layoutpage
    rename_column_if_exist :pages, :layout, :page_layout

    # Adds indexes
    add_index_unless_exist :contents, [:element_id, :position]
    add_index_unless_exist :elements, [:page_id, :position]
    add_index_unless_exist :pages, [:parent_id, :lft]

    # Change WaAtoms to Essences
    execute("UPDATE contents SET essence_type = REPLACE(essence_type, 'WaAtom', 'Essence')")
    execute("UPDATE contents SET essence_type = REPLACE(essence_type, 'EssenceRtf', 'EssenceRichtext')")
    execute("UPDATE contents SET essence_type = REPLACE(essence_type, 'EssenceFlashvideo', 'EssenceVideo')")

    # Renaming old userstamp columns to new userstamp columns
    rename_column_if_exist :pages, :created_by, :creator_id
    rename_column_if_exist :pages, :updated_by, :updater_id

    # Adding userstamps to tables
    add_column_unless_exist :essence_audios, :creator_id, :integer
    add_column_unless_exist :essence_audios, :updater_id, :integer
    add_column_unless_exist :attachments, :creator_id, :integer
    add_column_unless_exist :attachments, :updater_id, :integer
    add_column_unless_exist :contents, :creator_id, :integer
    add_column_unless_exist :contents, :updater_id, :integer
    add_column_unless_exist :essence_dates, :creator_id, :integer
    add_column_unless_exist :essence_dates, :updater_id, :integer
    add_column_unless_exist :essence_files, :creator_id, :integer
    add_column_unless_exist :essence_files, :updater_id, :integer
    add_column_unless_exist :essence_flashes, :creator_id, :integer
    add_column_unless_exist :essence_flashes, :updater_id, :integer
    add_column_unless_exist :essence_htmls, :creator_id, :integer
    add_column_unless_exist :essence_htmls, :updater_id, :integer
    add_column_unless_exist :essence_pictures, :creator_id, :integer
    add_column_unless_exist :essence_pictures, :updater_id, :integer
    add_column_unless_exist :essence_richtexts, :creator_id, :integer
    add_column_unless_exist :essence_richtexts, :updater_id, :integer
    add_column_unless_exist :essence_texts, :creator_id, :integer
    add_column_unless_exist :essence_texts, :updater_id, :integer
    add_column_unless_exist :essence_videos, :creator_id, :integer
    add_column_unless_exist :essence_videos, :updater_id, :integer
    add_column_unless_exist :pictures, :creator_id, :integer
    add_column_unless_exist :pictures, :updater_id, :integer
    add_column_unless_exist :elements, :creator_id, :integer
    add_column_unless_exist :elements, :updater_id, :integer
    add_column_unless_exist :users, :creator_id, :integer
    add_column_unless_exist :users, :updater_id, :integer

    # Adds timestamps
    add_column_unless_exist :attachments, :updated_at, :datetime
    add_column_unless_exist :contents, :created_at, :datetime
    add_column_unless_exist :contents, :updated_at, :datetime
    add_column_unless_exist :essence_audios, :created_at, :datetime
    add_column_unless_exist :essence_audios, :updated_at, :datetime
    add_column_unless_exist :essence_dates, :created_at, :datetime
    add_column_unless_exist :essence_dates, :updated_at, :datetime
    add_column_unless_exist :essence_files, :created_at, :datetime
    add_column_unless_exist :essence_files, :updated_at, :datetime
    add_column_unless_exist :essence_flashes, :created_at, :datetime
    add_column_unless_exist :essence_flashes, :updated_at, :datetime
    add_column_unless_exist :essence_htmls, :created_at, :datetime
    add_column_unless_exist :essence_htmls, :updated_at, :datetime
    add_column_unless_exist :essence_pictures, :created_at, :datetime
    add_column_unless_exist :essence_pictures, :updated_at, :datetime
    add_column_unless_exist :essence_richtexts, :created_at, :datetime
    add_column_unless_exist :essence_richtexts, :updated_at, :datetime
    add_column_unless_exist :essence_texts, :created_at, :datetime
    add_column_unless_exist :essence_texts, :updated_at, :datetime
    add_column_unless_exist :essence_videos, :created_at, :datetime
    add_column_unless_exist :essence_videos, :updated_at, :datetime
    add_column_unless_exist :pictures, :created_at, :datetime
    add_column_unless_exist :pictures, :updated_at, :datetime

    # Adds columns
    add_column_unless_exist :essence_pictures, :open_link_in_new_window, :boolean
    add_column_unless_exist :essence_texts, :open_link_in_new_window, :boolean
    add_column_unless_exist :pages, :restricted, :boolean, :default => false

    # Removes unused columns
    remove_column_if_exist :attachments, :parent_id
    remove_column_if_exist :attachments, :thumbnail
    remove_column_if_exist :attachments, :count
    remove_column_if_exist :essence_videos, :show_eq

    # Converts users table
    add_column_unless_exist :users, :gender, :string
    add_column_unless_exist :users, :role, :string
    change_column_if_exist :users, :crypted_password, :string, :limit => 128, :null => false, :default => ""
    change_column_if_exist :users, :salt, :string, :limit => 128, :null => false, :default => ""
    rename_column_if_exist :users, :salt, :password_salt
    remove_column_if_exist :users, :remember_token
    remove_column_if_exist :users, :remember_token_expires_at
    add_column_unless_exist :users, :login_count, :integer, :null => false, :default => 0
    add_column_unless_exist :users, :failed_login_count, :integer, :null => false, :default => 0
    add_column_unless_exist :users, :last_request_at, :datetime
    add_column_unless_exist :users, :current_login_at, :datetime
    add_column_unless_exist :users, :last_login_at, :datetime
    add_column_unless_exist :users, :current_login_ip, :string
    add_column_unless_exist :users, :last_login_ip, :string
    add_column_unless_exist :users, :persistence_token, :string, :null => false
    add_column_unless_exist :users, :single_access_token, :string, :null => false
    add_column_unless_exist :users, :perishable_token, :string, :null => false
    add_index_unless_exist :users, :perishable_token
    remove_column_if_exist :users, :admin
    execute("UPDATE users SET role = 'admin' WHERE role IS NULL")

    # Phew!
  end

  def self.down
    raise IrreversibleMigration
  end

private

  def self.rename_table_if_exist(*args)
    if table_exists?(args.first)
      rename_table(*args)
    end
  end

  def self.drop_table_if_exist(*args)
    if table_exists?(args.first)
      drop_table(*args)
    end
  end

  def self.rename_column_if_exist(*args)
    if column_exists?(*args[0..1])
      rename_column(*args)
    end
  end

  def self.remove_column_if_exist(*args)
    if column_exists?(*args[0..1])
      remove_column(*args)
    end
  end

  def self.add_column_unless_exist(*args)
    unless column_exists?(*args[0..1])
      add_column(*args)
    end
  end

  def self.add_index_unless_exist(*args)
    unless index_exists?(*args)
      add_index(*args)
    end
  end

  def self.remove_index_if_exist(*args)
    if table_exists?(args.first) && index_exists?(*args)
      remove_index(*args)
    end
  end

  def self.change_column_if_exist(*args)
    if column_exists?(*args[0..1])
      change_column(*args)
    end
  end

end
EOF
      File.open(new_name, 'w') { |f| f.puts(s) }
    end

    desc "Rename files and folders."
    task :rename_files_and_folders do
      if File.exists?('config/washapp')
        FileUtils.mv('config/washapp', 'config/alchemy')
      end
      if File.exists?('config/alchemy/molecules.yml')
        FileUtils.mv('config/alchemy/molecules.yml', 'config/alchemy/elements.yml')
      end
      if File.exists?('app/views/wa_molecules')
        FileUtils.mv('app/views/wa_molecules', 'app/views/elements')
      end
      if File.exists?('app/views/layouts/wa_pages.html.erb')
        FileUtils.mv('app/views/layouts/wa_pages.html.erb', 'app/views/layouts/pages.html.erb')
      end
      if File.exists?('app/views/wa_mailer')
        FileUtils.mv('app/views/wa_mailer', 'app/views/messages')
        if File.exists?('app/views/messages/mail.html.erb')
          FileUtils.mv('app/views/messages/mail.html.erb', 'app/views/messages/contact_form_mail.html.erb')
        end
        if File.exists?('app/views/messages/mail.text.erb')
          FileUtils.mv('app/views/messages/mail.text.erb', 'app/views/messages/contact_form_mail.text.erb')
        else
          FileUtils.touch('app/views/messages/contact_form_mail.text.erb')
        end
      end
      if File.exists?('public/uploads/files')
        FileUtils.mkdir_p('uploads')
        FileUtils.mv('public/uploads/files', 'uploads/attachments')
      end
      if File.exists?('public/uploads/images')
        FileUtils.mkdir_p('uploads')
        FileUtils.mv('public/uploads/images', 'uploads/pictures')
      end
    end

    desc "Converts elements descriptions"
    task :convert_elements => ['alchemy:legacy:rename_files_and_folders'] do
      file_name = 'config/alchemy/elements.yml'
      text = File.read(file_name)
      text.gsub!(/WaAtom/, 'Essence')
      text.gsub!(/EssenceRtf/, 'EssenceRichtext')
      text.gsub!(/EssenceFlashvideo/, 'EssenceVideo')
      text.gsub!(/wa_atoms/, 'contents')
      File.open(file_name, "w") { |file| file.puts text }
    end

    desc "Converts page layouts descriptions"
    task :convert_page_layouts => ['alchemy:legacy:rename_files_and_folders'] do
      file_name = 'config/alchemy/page_layouts.yml'
      text = File.read(file_name)
      text.gsub!(/molecules/, 'elements')
      File.open(file_name, "w") { |file| file.puts text }
    end

    desc "Converts views"
    task :convert_views do
      files = Dir.glob("app/views/**/*.erb")
      files.each do |file_name|
        text = File.read(file_name)
        text.gsub!(/wa_molecule/, 'element')
        text.gsub!(/wa_page/, 'page')
        text.gsub!(/WaMolecule/, 'Element')
        text.gsub!(/WaPage/, 'Page')
        text.gsub!(/WaPicture/, 'Picture')
        text.gsub!(/WaFile/, 'File')
        text.gsub!(/WaAtom/, 'Essence')
        text.gsub!(/EssenceRtf/, 'EssenceRichtext')
        text.gsub!(/EssenceFlashvideo/, 'EssenceVideo')
        text.gsub!(/\.wa_atoms/, '.contents')
        text.gsub!(/render_atom_view\(atom\,/, 'render_essence_view(content,')
        text.gsub!(/render_atom_view/, 'render_essence_view')
        text.gsub!(/render_atom_editor/, 'render_essence_editor')
        text.gsub!(/atom_type/, 'essence_type')
        text.gsub!(/\|atom\|/, '|content|')
        text.gsub!(/molecule_dom_id/, 'element_dom_id')
        text.gsub!(/\.atom\.content/, '.ingredient')
        text.gsub!(/\.atom_by_name/, '.content_by_name')
        text.gsub!(/\.find_by_layout/, '.find_by_page_layout')
        text.gsub!(/render_molecule/, 'render_element')
        text.gsub!(/index_url/, 'root_path')
        text.gsub!(/by_name_url\(/, 'show_page_path(:urlname => ')
        text.gsub!(/find_by_language_root_for\((.+)\)/, 'find_by_language_root_and_language_code(true, \1)')
        text.gsub!(/@mail_data\[\:(\S+)\]/, '@message.\1')
        text.gsub!(/@mail_data\["(\S+)"\]/, '@message.\1')
        text.gsub!(/@mail_data\['(\S+)'\]/, '@message.\1')
        File.open(file_name, "w") { |file| file.puts text }
      end
    end

    desc "Create languages for pages"
    task :create_languages => [:environment, 'alchemy:legacy:rename_files_and_folders'] do
      Page.all.each do |page|
        language = Language.find_or_create_by_code(
          :code => page.language_code,
          :name => page.language_code,
          :page_layout => 'intro',
          :frontpage_name => 'Intro'
        )
        page.language = language
        page.save(:validate => false)
      end
    end

    desc "Assign languages to layout pages"
    task :assign_languages_to_layout_pages => [:environment, 'alchemy:legacy:rename_files_and_folders'] do
      language = Language.get_default
      Page.layoutpages.each do |page|
        page.language = language
        page.save(:validate => false)
      end
    end

    desc "Copy configuration file."
    task :copy_config do
      config_file = 'config/alchemy/config.yml'
      default_config = File.join(File.dirname(__FILE__), '../../config/alchemy/config.yml')
      if FileUtils.identical? default_config, config_file
        puts "Configuration file already present."
      else
        puts "Custom configuration file found."
        FileUtils.cp default_config, 'config/alchemy/config.yml.defaults'
        puts "Copied new default configuration file."
        puts "Check the default configuration file (./config/alchemy/config.yml.defaults) for new configuration options and insert them into your config file."
      end
    end

  end
end
