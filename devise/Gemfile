source "https://rubygems.org"

alchemy_branch = ENV.fetch("ALCHEMY_BRANCH", "6.1-stable")
gem "alchemy_cms", github: "AlchemyCMS/alchemy_cms", branch: alchemy_branch

gem "rails", "~> 7.0.0"
gem "listen", "~> 3.8"
gem "puma", "~> 6.0"

# Specify your gem's dependencies in alchemy-solidus.gemspec
gemspec

group :test do
  gem "sqlite3" if ENV["DB"].nil? || ENV["DB"] == "sqlite"
  gem "mysql2" if ENV["DB"] == "mysql"
  gem "pg", "~> 1.0" if ENV["DB"] == "postgresql"
end

gem "github_fast_changelog", require: false

gem "standardrb", "~> 1.0", require: false
