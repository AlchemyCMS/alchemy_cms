source "https://rubygems.org"

alchemy_branch = ENV.fetch("ALCHEMY_BRANCH", "main")
gem "alchemy_cms", github: "AlchemyCMS/alchemy_cms", branch: alchemy_branch

if alchemy_branch == "main"
  gem "jsbundling-rails", "~> 1.1"
end

gem "rails", "~> 6.1.7"
gem "listen", "~> 3.8"

# Specify your gem's dependencies in alchemy-solidus.gemspec
gemspec

group :test do
  gem "sqlite3" if ENV["DB"].nil? || ENV["DB"] == "sqlite"
  gem "mysql2" if ENV["DB"] == "mysql"
  gem "pg", "~> 1.0" if ENV["DB"] == "postgresql"
end

gem "github_fast_changelog", require: false
