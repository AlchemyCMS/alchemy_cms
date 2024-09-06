source "https://rubygems.org"

alchemy_branch = ENV.fetch("ALCHEMY_BRANCH", "main")
gem "alchemy_cms", github: "AlchemyCMS/alchemy_cms", branch: alchemy_branch

rails_version = ENV.fetch("RAILS_VERSION", "7.1")
gem "rails", "~> #{rails_version}.0"
gem "listen", "~> 3.8"
gem "puma", "~> 6.0"

# Specify your gem's dependencies in alchemy-solidus.gemspec
gemspec

group :test do
  if ENV["DB"].nil? || ENV["DB"] == "sqlite"
    gem "sqlite3", "~> 1.4"
  end
  gem "mysql2" if ENV["DB"] == "mysql"
  gem "pg", "~> 1.0" if ENV["DB"] == "postgresql"
end

gem "github_fast_changelog", require: false

gem "standardrb", "~> 1.0", require: false
