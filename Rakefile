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

APP_RAKEFILE = File.expand_path('spec/dummy/Rakefile', __dir__)
load 'rails/tasks/engine.rake'

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: ['alchemy:spec:prepare', :spec]

Bundler::GemHelper.install_tasks

namespace :alchemy do
  namespace :spec do
    desc "Prepares database for testing Alchemy"
    task :prepare do
      system(
        <<~BASH
          cd spec/dummy && \
          export RAILS_ENV=test && \
          bin/rake db:create && \
          bin/rake db:environment:set && \
          bin/rake db:migrate:reset && \
          bin/rails g alchemy:install --skip --skip-demo-files --auto-accept && \
          cd -
        BASH
      ) || fail
    end
  end

  namespace :changelog do
    desc "Update CHANGELOG from GitHub (Set GITHUB_ACCESS_TOKEN and PREVIOUS_VERSION to a version you want to write changelog changes for)"
    task :update do
      original_file = './CHANGELOG.md'
      new_file = original_file + '.new'
      backup = original_file + '.old'
      changes = `git rev-list v#{ENV['PREVIOUS_VERSION']}..HEAD | bundle exec github_fast_changelog AlchemyCMS/alchemy_cms`
      File.open(new_file, 'w') do |fo|
        fo.puts changes
        File.foreach(original_file) do |li|
          fo.puts li
        end
        fo.puts ""
      end
      File.rename(original_file, backup)
      File.rename(new_file, original_file)
      File.delete(backup)
    end
  end
end
