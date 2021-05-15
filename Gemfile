# frozen_string_literal: true
source "https://rubygems.org"

gemspec

rails_version = ENV.fetch("RAILS_VERSION", 6.0).to_f
gem "rails", "~> #{rails_version}.0"

if ENV["DB"].nil? || ENV["DB"] == "sqlite"
  gem "sqlite3", "~> 1.4.1"
end
gem "mysql2", "~> 0.5.1" if ENV["DB"] == "mysql"
gem "pg", "~> 1.0" if ENV["DB"] == "postgresql"

group :development, :test do
  # execjs 2.8 removes deprecation warnings but also breaks a number of dependent projects.
  # in our case the culprit is `handlebars-assets`. The changes between 2.7.0 and 2.8.0 are
  # minimal, but breaking.
  gem "execjs", "= 2.8.1"

  if ENV["GITHUB_ACTIONS"]
    # Necessary because GH Actions gem cache does not have this "Bundled with Ruby" gem installed
    gem "rexml", "~> 3.2.4"
    gem "sassc", "~> 2.4.0" # https://github.com/sass/sassc-ruby/issues/146
  else
    gem "launchy"
    gem "annotate"
    gem "bumpy"
    gem "yard"
    gem "redcarpet"
    gem "pry-byebug"
    gem "rubocop", "1.5.2", require: false
    gem "listen"
    gem "localeapp", "~> 3.0", require: false
    gem "dotenv", "~> 2.2"
    gem "github_fast_changelog", require: false
    gem "active_record_query_trace", require: false
    gem "rack-mini-profiler", require: false
    gem "rufo", require: false
    gem "brakeman", require: false
  end
end
