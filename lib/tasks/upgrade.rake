namespace :alchemy do
  namespace :legacy do

    desc "Upgrades your database to Alchemy 2.0"
    task :upgrade do
      Rake::Task['alchemy:legacy:generate_migration'].invoke
      Rake::Task['alchemy:migrations:sync'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['alchemy:legacy:convert_page_layouts'].invoke
      Rake::Task['alchemy:legacy:convert_elements'].invoke
      Rake::Task['alchemy:legacy:create_element_translations'].invoke
      Rake::Task['alchemy:legacy:create_page_layouts_translations'].invoke
      Rake::Task['alchemy:legacy:convert_views'].invoke
      Rake::Task['alchemy:legacy:convert_models_and_methods'].invoke
      Rake::Task['alchemy:legacy:copy_config'].invoke
      Alchemy::Seeder.seed!
      Rake::Task['alchemy:legacy:create_languages'].invoke
      Rake::Task['alchemy:legacy:assign_languages_to_layout_pages'].invoke
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
      Page.all.each do |page|
        language = Language.find_or_create_by_code(
          :code => page.language_code || ::I18n.default_locale,
          :name => page.language_code || ::I18n.default_locale,
          :page_layout => 'intro',
          :frontpage_name => 'Intro'
        )
        language.update_attribute(:default, Language.all.first == language)
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
        FileUtils.mv config_file, 'config/alchemy/config.yml.backup'
        puts "Backuped configuration file to config/alchemy/config.yml.backup."
        FileUtils.cp default_config, 'config/alchemy/config.yml'
        puts "Copied new default configuration file."
        puts "Check the configuration file (./config/alchemy/config.yml) and adopt settings from your old configuration (config/alchemy/config.yml.backup)."
      end
    end

    desc "Generates element names translations."
    task :create_element_translations => [:environment, 'alchemy:legacy:convert_elements'] do
      create_translations_for('element')
    end

    desc "Generates page_layout names translations."
    task :create_page_layouts_translations => [:environment, 'alchemy:legacy:convert_page_layouts'] do
      create_translations_for('page_layout')
    end

    def create_translations_for(entity)
      lang = ::I18n.default_locale.to_s
      entities = YAML.load_file("config/alchemy/#{entity}s.yml")
      abort "No #{entity} descriptions found. Please check #{entity}s.yml file." if entities.blank?
      locale_file = "config/locales/#{lang}.yml"
      # load or create locale hash
      if File.exists?(locale_file)
        locale = YAML.load_file(locale_file)
      else
        locale = {lang => {'alchemy' => {"#{entity}_names" => {}}}}
      end
      # preparing the locale file
      locale[lang] ||= {'alchemy' => {"#{entity}_names" => {}}}
      locale[lang]['alchemy'] ||= {"#{entity}_names" => {}}
      locale[lang]['alchemy']["#{entity}_names"] ||= {}
      # store page_layout names in locale file
      entities.each do |e|
        locale[lang]['alchemy']["#{entity}_names"].merge!(e['name'] => e['display_name'])
      end
      # write the file out
      File.open(locale_file, "w") do |f|
        f.write(locale.to_yaml.sub("---\n", ''))
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
        text.gsub!(/(render_essence_view_by_type.*\s)0/, '\11')
        text.gsub!(/atom_type/, 'essence_type')
        text.gsub!(/\|atom\|/, '|content|')
        text.gsub!(/\.atom\.content/, '.ingredient')
        text.gsub!(/\.atom_by_name/, '.content_by_name')
        text.gsub!(/\.atom/, '.essence')
        text.gsub!(/"atoms\[atom_#\{(.+)\..+\}\]\[.+\]"/, '\1.form_field_name')
        text.gsub!(/wa_atom/, 'content')
        text.gsub!(/atom/, 'content')
        text.gsub!(/molecule_dom_id/, 'element_dom_id')
        text.gsub!(/\.find_by_layout/, '.find_by_page_layout')
        text.gsub!(/render_molecule/, 'render_element')
        text.gsub!(/index_url/, 'root_path')
        text.gsub!(/by_name_url\(/, 'show_page_path(:urlname => ')
        text.gsub!(/\.contents\.find_by_name/, '.content_by_name')
        text.gsub!(/\.contents\.find_by_essence_type/, '.content_by_type')
        text.gsub!(/\.contents\.find_all_by_essence_type/, '.all_contents_by_type')
        text.gsub!(/\.contents\.find_all_by_name/, '.all_contents_by_name')
        text.gsub!(/\.content_by_name\("(.+)"\)\.ingredient/, '.ingredient(:\1)')
        text.gsub!(/find_by_language_root_for\((.+)\)/, 'language_roots.where(:language_code => \1).first')
        text.gsub!(/@mail_data\[\:(\S+)\]/, '@message.\1')
        text.gsub!(/@mail_data\["(\S+)"\]/, '@message.\1')
        text.gsub!(/@mail_data\['(\S+)'\]/, '@message.\1')
        text.gsub!(/\.get_root\("\S+"\)/, '.language_root_for(session[:language_id])')
        text.gsub!(/@?current_page/, '@page')
        text.gsub!(/logged_in\?/, 'current_user')
        text.gsub!(/, :css_class => 'text_long'/, '')
        File.open(file_name, "w") { |file| file.puts text }
      end
    end

  end
end
