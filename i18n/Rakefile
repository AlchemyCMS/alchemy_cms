begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'bundler/gem_tasks'

require "github_changelog_generator/task"
require "alchemy_i18n/version"
GitHubChangelogGenerator::RakeTask.new(:changelog) do |config|
  config.user = "AlchemyCMS"
  config.project = "alchemy_i18n"
  config.future_release = "v#{AlchemyI18n::VERSION}"
end
