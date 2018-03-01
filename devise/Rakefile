begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'AlchemyDevise'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => ['alchemy:spec:prepare', :spec]

Bundler::GemHelper.install_tasks

namespace :alchemy do
  namespace :spec do
    desc "Prepares database for testing Alchemy"
    task :prepare do
      system <<-BASH
cd spec/dummy
export RAILS_ENV=test
bin/rake db:create db:environment:set db:migrate
bin/rails g alchemy:devise:install --force
cd -
BASH
    end
  end
end
