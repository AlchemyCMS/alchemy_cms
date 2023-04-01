begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

require "rdoc/task"

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "AlchemyDevise"
  rdoc.options << "--line-numbers"
  rdoc.rdoc_files.include("README.md")
  rdoc.rdoc_files.include("lib/**/*.rb")
  rdoc.rdoc_files.include("app/**/*.rb")
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load "rails/tasks/engine.rake"

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => ["alchemy:spec:prepare", :spec]

Bundler::GemHelper.install_tasks

namespace :alchemy do
  namespace :spec do
    desc "Prepares database for testing Alchemy"
    task :prepare do
      Dir.chdir("spec/dummy") do
        if ENV["ALCHEMY_BRANCH"] == "main"
          system("bin/rails javascript:install:esbuild") || exit($?.exitstatus)
        end
        system(
          <<~SETUP
            bin/rake railties:install:migrations
            bin/rake db:drop db:create db:migrate
            bin/rails g alchemy:install --force --auto-accept
            bin/rails g alchemy:devise:install --force
          SETUP
        )
        exit($?.exitstatus) unless $?.success?
        if ENV["ALCHEMY_BRANCH"] == "main"
          system("bin/rails javascript:build") || exit($?.exitstatus)
        else
          system("bin/rails webpacker:compile") || exit($?.exitstatus)
        end
      end
    end
  end

  namespace :changelog do
    desc "Update changelog"
    task :update do
      original_file = "./CHANGELOG.md"
      new_file = original_file + ".new"
      backup = original_file + ".old"
      changes = `git rev-list v#{ENV["PREVIOUS_VERSION"]}...main | bundle exec github_fast_changelog AlchemyCMS/alchemy-devise`
      File.open(new_file, "w") do |fo|
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
