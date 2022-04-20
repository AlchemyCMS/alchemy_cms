source "https://rubygems.org"

alchemy_branch = ENV.fetch("ALCHEMY_BRANCH", "main")
gem "alchemy_cms", github: "AlchemyCMS/alchemy_cms", branch: alchemy_branch

gem "rails", "~> 6.1.5"

# Specify your gem's dependencies in alchemy-solidus.gemspec
gemspec

group :test do
  gem "sqlite3" if ENV["DB"].nil? || ENV["DB"] == "sqlite"
  gem "mysql2" if ENV["DB"] == "mysql"
  gem "pg", "~> 1.0" if ENV["DB"] == "postgresql"
end

gem "github_fast_changelog", require: false
