# encoding: UTF-8
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the alchemy plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the alchemy plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Alchemy'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('config/alchemy/*.yml')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end

namespace :gettext do
  def load_gettext
    require 'gettext'
    require 'gettext/tools'
  end
  
  desc "Create mo-files for L10n"
  task :pack do
    load_gettext
    GetText.create_mofiles(:verbose => true, :po_root => "locale", :mo_root => "locale")
  end
  
  desc "Update pot/po files."
  task :find do
    load_gettext
    $LOAD_PATH << File.join(File.dirname(__FILE__),'plugins','gettext_i18n_rails','lib')
    require 'gettext_i18n_rails/haml_parser'
    
    if GetText.respond_to? :update_pofiles_org
      GetText.update_pofiles_org(
        "alchemy",
        Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,haml,rjs}"),
        "version 2.0",
        :po_root => 'locale',
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
        "alchemy",
        Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,haml,rjs}"),
        "version 2.0",
        'locale'
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
  desc "write the locale/model_attributes.rb"
  task :store_model_attributes => :environment do
    FastGettext.silence_errors
    require 'gettext_i18n_rails/model_attributes_finder'
    storage_file = 'locale/model_attributes.rb'
    puts "writing model translations to: #{storage_file}"
    GettextI18nRails.store_model_attributes(
      :to=>storage_file,
      :ignore_columns=>[/_id$/,'id','type','created_at','updated_at'],
      :ignore_tables=>[/^sitemap_/,/_versions$/,'schema_migrations']
    )
  end
end

require File.join(File.dirname(__FILE__), "lib", "alchemy")
begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "alchemy"
    gem.version = Alchemy.version
    gem.summary = "Alchemy CMS"
    gem.description = "A CMS for Rails 3"
    gem.rubyforge_project = "alchemy"
    gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*", "{assets}/**/*", "{db}/**/*", "{generators}/**/*", "{locale}/**/*", "{recipes}/**/*", "{test}/**/*"]
    gem.email = "alchemy@magiclabs.de"
    gem.homepage = "http://github.com/magiclabs/alchemy"
    gem.authors = `git log --pretty=format:"%an"`.split("\n").uniq.sort
    gem.add_dependency 'rails', '>= 3.0.7', '< 3.1'
    gem.add_dependency 'mysql2', '>= 0.2', '< 0.3'
    gem.add_dependency 'authlogic', '>= 3.0.3'
    gem.add_dependency 'awesome_nested_set', '>= 2.0.0'
    gem.add_dependency 'declarative_authorization', '>= 0.5'
    gem.add_dependency "tvdeyen-fleximage", ">= 1.0.5"
    gem.add_dependency 'gettext_i18n_rails', '>= 0.2.19'
    gem.add_dependency 'will_paginate', '>= 3.0.pre'
    gem.add_dependency 'acts_as_ferret', '>= 0.5.2'
    gem.add_dependency 'mimetype-fu', '>= 0.1.2'
    gem.add_dependency 'sortifiable', '>= 0.2.3'
    gem.add_dependency 'userstamp', '>= 2.0.1'
    gem.add_dependency 'dynamic_form', '>= 1.1.4'
  end
rescue LoadError
  puts "Jeweler or one of its dependencies is not installed."
end
