#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

desc 'Generate documentation for Alchemy CMS.'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Alchemy CMS'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('config/alchemy/*.yml')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

require 'rspec/core'
require 'rspec/core/rake_task'

task :default => ['alchemy:spec:run']

Bundler::GemHelper.install_tasks

namespace :alchemy do
  namespace :spec do

    desc "Prepares database for testing Alchemy"
    task :prepare do
      system 'cd spec/dummy && RAILS_ENV=test bundle exec rake db:drop db:create db:migrate:reset && cd -'
    end

    desc "Run all Alchemy specs"
    task :run do
      Rake::Task['alchemy:spec:prepare'].invoke
      Rake::Task['alchemy:spec:transactionals'].invoke
      Rake::Task['alchemy:spec:truncationals'].invoke
    end

    Rspec::Core::RakeTask.new(:transactionals) do |t|
      t.pattern = Dir['spec/*/**/*_spec.rb'].reject{ |f| f['/features'] }
    end

    Rspec::Core::RakeTask.new(:truncationals) do |t|
      t.pattern = "spec/features/**/*_spec.rb"
    end

  end
end
