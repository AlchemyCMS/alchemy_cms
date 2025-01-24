# frozen_string_literal: true

source "https://rubygems.org"

gemspec

rails_version = ENV.fetch("RAILS_VERSION", "8.0")
gem "rails", "~> #{rails_version}.0"

if ENV["DB"].nil? || ENV["DB"] == "sqlite"
  gem "sqlite3", (rails_version == "7.0") ? "~> 1.7" : "~> 2.0"
end
if ENV["DB"] == "mysql" || ENV["DB"] == "mariadb"
  gem "mysql2", "~> 0.5.1"
end
gem "pg", "~> 1.0" if ENV["DB"] == "postgresql"

gem "alchemy_i18n", github: "AlchemyCMS/alchemy_i18n", branch: "main"

group :development, :test do
  gem "execjs", "~> 2.9.1"
  gem "rubocop", require: false
  gem "standard", "~> 1.25", require: false

  # Still need Sprockets for tests
  gem "sprockets", "~> 4.2", ">= 4.2.1", require: false

  if ENV["GITHUB_ACTIONS"]
    gem "simplecov-cobertura", "~> 2.1"

    # https://github.com/hotwired/turbo-rails/issues/512
    if rails_version == "7.1"
      gem "actioncable", "~> #{rails_version}.0"
    end

    # concurrent-ruby v1.3.5 has removed the dependency on logger,
    # effecting Rails 6.1 up to including 7.0.
    # https://github.com/rails/rails/pull/54264
    if ("6.1".to_f.."7.0".to_f).cover?(rails_version.to_f)
      gem "concurrent-ruby", "< 1.3.5"
    end
  else
    gem "launchy"
    gem "annotate"
    gem "bumpy"
    gem "yard"
    gem "redcarpet"
    gem "debug"
    gem "listen"
    gem "localeapp", "~> 3.0", require: false
    gem "dotenv", "~> 3.0"
    gem "github_fast_changelog", require: false
    gem "active_record_query_trace", require: false
    gem "rack-mini-profiler", require: false
    gem "brakeman", require: false
  end
end

# Ruby 3.1 split out the net-smtp gem
# Necessary until https://github.com/mikel/mail/pull/1439
# got merged and released.
if Gem.ruby_version >= Gem::Version.new("3.1.0")
  gem "net-smtp", "~> 0.4.0", require: false
end

gem "web-console", "~> 4.2", group: :development

gem "rails_live_reload", "~> 0.4.0"

gem "dartsass-rails", "~> 0.5.0"

gem "propshaft", "~> 1.0"

gem "gem-release", "~> 2.2"
