# encoding: UTF-8
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

import File.join(File.dirname(__FILE__), 'lib/tasks/gettext.rake')

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

require 'bundler'
Bundler::GemHelper.install_tasks
