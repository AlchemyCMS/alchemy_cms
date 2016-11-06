source "https://rubygems.org"

gemspec

gem 'alchemy_cms', github: 'AlchemyCMS/alchemy_cms', branch: 'master'
gem 'sassc-rails'

unless ENV['CI']
  gem 'pry'
  gem 'spring-commands-rspec'
  gem 'launchy'
end

group :test do
  gem 'sqlite3' if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
  gem 'mysql2'  if ENV['DB'] == 'mysql'
  gem 'pg'      if ENV['DB'] == 'postgresql'
  gem 'simplecov', require: false
  if ENV['TRAVIS']
    gem "codeclimate-test-reporter", '~> 1.0', require: false
  end
end
