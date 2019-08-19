source 'https://rubygems.org'

gemspec

gem 'rails', '~> 5.2.0'

# Profiling
gem 'rack-mini-profiler', group: :development, require: false

gem 'sqlite3', '~> 1.4.1' if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
gem 'mysql2', '~> 0.5.1' if ENV['DB'] == 'mysql'
gem 'pg',     '~> 1.0'   if ENV['DB'] == 'postgresql'
gem 'sassc-rails'

group :development, :test do
  gem 'simplecov', require: false
  gem 'bootsnap', require: false
  if ENV['TRAVIS']
    gem 'codeclimate-test-reporter', '~> 1.0', require: false
  end
  unless ENV['CI']
    gem 'launchy'
    gem 'annotate'
    gem 'bumpy'
    gem 'yard'
    gem 'redcarpet'
    gem 'pry-byebug'
    gem 'rubocop', require: false
    gem 'listen'
    gem 'localeapp', '~> 3.0', require: false
    gem 'dotenv', '~> 2.2'
    gem 'github_fast_changelog', require: false
  end
end

# We need this if we want to start the dummy app in production, ie on Teatro.io
group :production do
  gem 'uglifier', '>= 2.7.2'
  gem 'therubyracer'
end
