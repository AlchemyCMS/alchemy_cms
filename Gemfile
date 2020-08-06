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
  if ENV["TRAVIS"]
    gem "sassc", "~> 2.4.0" # https://github.com/sass/sassc-ruby/issues/146
  else
    gem "launchy"
    gem "annotate"
    gem "bumpy"
    gem "yard"
    gem "redcarpet"
    gem "pry-byebug"
    gem "rubocop", "~> 0.89.0", require: false
    gem "listen"
    gem "localeapp", "~> 3.0", require: false
    gem "dotenv", "~> 2.2"
    gem "github_fast_changelog", require: false
    gem "active_record_query_trace", require: false
    gem "rack-mini-profiler", require: false
    gem "rufo", require: false
  end
end
