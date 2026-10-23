begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

begin
  require "rdoc/task"
rescue LoadError
  require "rdoc/rdoc"
  require "rake/rdoctask"
  RDoc::Task = Rake::RDocTask
end

desc "Generate documentation for Alchemy CMS."
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "Alchemy CMS"
  rdoc.options << "--line-numbers" << "--inline-source"
  rdoc.rdoc_files.include("README.md")
  rdoc.rdoc_files.include("config/alchemy/*.yml")
  rdoc.rdoc_files.include("lib/**/*.rb")
  rdoc.rdoc_files.include("app/**/*.rb")
end

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

require "rspec/core"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: "alchemy:test:all"

namespace :alchemy_i18n do
  Bundler::GemHelper.new(File.expand_path("i18n", __dir__), "alchemy_i18n").install
end

namespace :alchemy_devise do
  Bundler::GemHelper.new(File.expand_path("devise", __dir__), "alchemy-devise").install
end

Bundler::GemHelper.install_tasks
task build: "alchemy_i18n:build"
task release: "alchemy_i18n:release:rubygem_push"
task build: "alchemy_devise:build"
task release: "alchemy_devise:release:rubygem_push"

namespace :alchemy do
  namespace :test do
    desc "Prepares database for testing Alchemy"
    task :prepare do
      system(
        <<~BASH
          cd spec/dummy && \
          export RAILS_ENV=test && \
          bin/rake db:create && \
          bin/rake db:environment:set && \
          bin/rake db:migrate:reset && \
          bin/rails g alchemy:install --skip --skip-demo-files --auto-accept --skip-db-create && \
          bin/rails dartsass:build && \
          cd -
        BASH
      ) || fail
    end

    desc "Prepares the database and runs the Alchemy core specs"
    task core: :prepare do
      sh "bin/rspec", "spec"
    end

    desc "Prepares the database and runs the alchemy-devise specs"
    task devise: :prepare do
      sh "bin/rspec", "devise/spec"
    end

    desc "Prepares the database and runs all specs"
    task all: [:core, :devise]
  end

  namespace :changelog do
    desc "Update CHANGELOG from GitHub (Set GITHUB_ACCESS_TOKEN and PREVIOUS_VERSION to a version you want to write changelog changes for)"
    task :update do
      original_file = "./CHANGELOG.md"
      new_file = original_file + ".new"
      backup = original_file + ".old"
      changes = `git rev-list v#{ENV["PREVIOUS_VERSION"]}..HEAD | bundle exec github_fast_changelog AlchemyCMS/alchemy_cms`.split("\n")
      changelog = File.read(original_file)
      File.open(new_file, "w") do |file|
        file.puts "# Changelog"
        file.puts ""
        file.puts "## Unreleased"
        file.puts ""
        changes.each do |change|
          next if changelog.include?(change)
          file.puts change
        end
        File.foreach(original_file) do |line|
          next if line.include?("# Changelog")
          file.puts line
        end
        file.puts ""
      end
      File.rename(original_file, backup)
      File.rename(new_file, original_file)
      File.delete(backup)
    end
  end

  desc "Release a new version of Alchemy to rubygems.org"
  task :release do
    require_relative "lib/alchemy/version"
    ENV["PREVIOUS_VERSION"] = Alchemy::VERSION
    system("bundle exec gem bump --version #{ENV.fetch("VERSION", "patch")}")
    load "./lib/alchemy/version.rb"
    new_version = Alchemy::VERSION
    Rake::Task["alchemy:changelog:update"].invoke
    changelog = File.read("CHANGELOG.md").gsub(/(##) Unreleased/, "## #{new_version} (#{Time.now.strftime("%Y-%m-%d")})")
    File.open("CHANGELOG.md", "w") { |file| file.puts changelog }
    system("git add CHANGELOG.md")
    system("git commit --amend --no-edit")
    system("gem tag")
    Rake::Task["release"].invoke
    system("git push --follow-tags")
  end
end
