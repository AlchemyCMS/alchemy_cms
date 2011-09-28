namespace :gettext do
  def load_gettext
    require 'gettext'
    require 'gettext/utils'
  end

  desc "Create mo-files for L10n"
  task :pack => :environment do
    load_gettext
    GetText.create_mofiles(true, locale_path, locale_path)
  end

  desc "Update pot/po files."
  task :find => :environment do
    load_gettext
    $LOAD_PATH << File.join(File.dirname(__FILE__),'..','..','lib')
    require 'gettext_i18n_rails/haml_parser'


    if GetText.respond_to? :update_pofiles_org
      GetText.update_pofiles_org(
        text_domain,
        files_to_translate,
        "version 0.0.1",
        :po_root => locale_path,
        :msgmerge=>['--sort-output']
      )
    else #we are on a version < 2.0
      puts "install new GetText with gettext:install to gain more features..."
      #kill ar parser...
      require 'gettext/parser/active_record'
      module GetText
        module ActiveRecordParser
          module_function
          def init(x);end
        end
      end

      #parse files.. (models are simply parsed as ruby files)
      GetText.update_pofiles(
        text_domain,
        files_to_translate,
        "version 0.0.1",
        locale_path
      )
    end
  end

  # This is more of an example, ignoring
  # the columns/tables that mostly do not need translation.
  # This can also be done with GetText::ActiveRecord
  # but this crashed too often for me, and
  # IMO which column should/should-not be translated does not
  # belong into the model
  #
  # You can get your translations from GetText::ActiveRecord
  # by adding this to you gettext:find task
  #
  # require 'active_record'
  # gem "gettext_activerecord", '>=0.1.0' #download and install from github
  # require 'gettext_activerecord/parser'
  desc "write the model attributes to <locale_path>/model_attributes.rb"
  task :store_model_attributes => :environment do
    FastGettext.silence_errors

    require 'gettext_i18n_rails/model_attributes_finder'
    require 'gettext_i18n_rails/active_record'

    storage_file = "#{locale_path}/model_attributes.rb"
    puts "writing model translations to: #{storage_file}"

    ignore_tables = [/^sitemap_/, /_versions$/, 'schema_migrations', 'sessions', 'delayed_jobs']
    GettextI18nRails.store_model_attributes(
      :to => storage_file,
      :ignore_columns => [/_id$/, 'id', 'type', 'created_at', 'updated_at'],
      :ignore_tables => ignore_tables
    )
  end

  desc "add a new language"
  task :add_language, [:language] => :environment do |_, args|
    language = args.language || ENV["LANGUAGE"]

    # Let's do some pre-verification of the environment.
    if language.nil?
      puts "You need to specify the language to add. Either 'LANGUAGE=eo rake gettext:add_languange' or 'rake gettext:add_languange[eo]'"
      next
    end
    pot = File.join(locale_path, "#{text_domain}.pot")
    if !File.exists? pot
      puts "You don't have a pot file yet, you probably should run 'rake gettext:find' at least once. Tried '#{pot}'."
      next
    end

    # Create the directory for the new language.
    dir = File.join(locale_path, language)
    puts "Creating directory #{dir}"
    Dir.mkdir dir

    # Create the po file for the new language.
    new_po = File.join(locale_path, language, "#{text_domain}.po")
    puts "Initializing #{new_po} from #{pot}."
    system "msginit --locale=#{language} --input=#{pot} --output=#{new_po}"
  end

  def locale_path
    FastGettext.translation_repositories[text_domain].instance_variable_get(:@options)[:path]
  rescue
    File.join(RAILS_ROOT, "locale")
  end

  def text_domain
    # if your textdomain is not 'app': require the environment before calling e.g. gettext:find OR add TEXTDOMAIN=my_domain
    ENV['TEXTDOMAIN'] || (FastGettext.text_domain rescue nil) || "app"
  end

  def files_to_translate
    Dir.glob("{app,lib,config,#{locale_path}}/**/*.{rb,erb,haml}")
  end
end