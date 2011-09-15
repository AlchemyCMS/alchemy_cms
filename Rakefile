# encoding: UTF-8
require 'rubygems'
begin
  require 'bundler'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rake/rdoctask'

require 'rspec/core'
require 'rspec/core/rake_task'

import File.join(File.dirname(__FILE__), 'lib/tasks/gettext.rake')

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Bundler::GemHelper.install_tasks

desc 'Generate documentation for the alchemy plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Alchemy CMS'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('config/alchemy/*.yml')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end
