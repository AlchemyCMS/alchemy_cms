namespace :alchemy do
  namespace :legacy do

    desc "Upgrades your database to Alchemy 2.0"
    task :upgrade do
      Rake::Task['alchemy:legacy:generate_migration'].invoke
      Rake::Task['alchemy:migrations:sync'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['alchemy:legacy:convert_page_layouts'].invoke
      Rake::Task['alchemy:legacy:convert_elements'].invoke
      Rake::Task['alchemy:legacy:convert_views'].invoke
      Rake::Task['alchemy:legacy:convert_models_and_methods'].invoke
      Alchemy::Seeder.seed!
      Rake::Task['alchemy:legacy:create_languages'].invoke
      Rake::Task['alchemy:legacy:assign_languages_to_layout_pages'].invoke
      Rake::Task['alchemy:legacy:copy_config'].invoke
    end

    desc "Generates a migration file for migrate the database schema from legacy versions to Alchemy."
    task :generate_migration do
      migration_file = File.join(File.dirname(__FILE__), 'templates/upgrade_database_to_alchemy.rb')
      destination_file = 'db/migrate/20100607143120_upgrade_database_to_alchemy.rb'
      if File.exists? destination_file
        puts "Legacy database migration already exist. Skipping."
      else
        FileUtils.cp migration_file, destination_file
        puts "Successfully created legacy database migration."
      end
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
      replace_models_and_methods(files)
    end

    desc "Convert models and methods"
    task :convert_models_and_methods do
      files = Dir.glob("app/**/*.rb")
      replace_models_and_methods(files)
    end

    desc "Create languages for pages"
    task :create_languages => [:environment, 'alchemy:legacy:rename_files_and_folders'] do
      pages = Page.all
      pages.each do |page|
        language = Language.find_or_create_by_code(
          :code => page.language_code || ::I18n.default_locale,
          :name => page.language_code || ::I18n.default_locale,
          :page_layout => 'intro',
          :frontpage_name => 'Intro',
          :default => pages.first == page
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

    def replace_models_and_methods(files)
      files.each do |file_name|
        text = File.read(file_name)
        text.gsub!(/wa_molecule/, 'element')
        text.gsub!(/molecule/, 'element')
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
        text.gsub!(/\.get_root\("\S+"\)/, '.language_root_for(session[:language_id])')
        text.gsub!(/\scurrent_page/, ' @page')
        File.open(file_name, "w") { |file| file.puts text }
      end
    end

  end
end
