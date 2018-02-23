source 'https://rubygems.org'

gemspec

gem 'rails', '~> 5.2.0'

# Profiling
gem 'rack-mini-profiler', group: :development, require: false

gem 'sqlite3' if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
gem 'mysql2', '~> 0.5.1' if ENV['DB'] == 'mysql'
gem 'pg',     '~> 1.0'   if ENV['DB'] == 'postgresql'
gem 'sassc-rails'

group :development, :test do
  gem 'simplecov', require: false
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
    gem 'spring'
    gem 'spring-commands-rspec'
    gem 'rubocop', require: false
    gem 'listen'
    gem 'localeapp', '~> 3.0', require: false
    gem 'dotenv', '~> 2.2'
  end
  gem 'capybara', '~> 3.0'
  gem 'capybara-screenshot', '~> 1.0'
  gem 'database_cleaner', '~> 1.3'
  gem 'factory_bot_rails', '~> 4.5'
  gem 'selenium-webdriver', '~> 3.8'
  gem 'rspec-activemodel-mocks', '~> 1.0'
  gem 'rspec-rails', '~> 3.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'rails-controller-testing', '~> 1.0'
end

# We need this if we want to start the dummy app in production, ie on Teatro.io
group :production do
  gem 'uglifier', '>= 2.7.2'
  gem 'therubyracer'
end
