source 'https://rubygems.org'

gemspec

gem 'sqlite3' if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
gem 'mysql2', '~> 0.3.18' if ENV['DB'] == 'mysql'
gem 'pg'      if ENV['DB'] == 'postgresql'
gem 'sassc-rails'

group :development, :test do
  gem 'jasmine-rails',        github: 'searls/jasmine-rails'
  gem 'jasmine-jquery-rails', github: 'travisjeffery/jasmine-jquery-rails'
  if ENV['TRAVIS']
    gem "codeclimate-test-reporter", require: false
  else
    gem 'simplecov',                 require: false
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
  end
  gem 'capybara', '~> 2.4'
  gem 'database_cleaner', '~> 1.3'
  gem 'factory_girl_rails', '~> 4.5'
  gem 'poltergeist', '~> 1.5'
  gem 'rspec-activemodel-mocks', '~> 1.0'
  gem 'rspec-rails', '~> 3.0'
  gem 'shoulda-matchers', '~> 3.1'
end

# We need this if we want to start the dummy app in development mode
group :development, :production do
  gem 'quiet_assets'
end

# We need this if we want to start the dummy app in production, ie on Teatro.io
group :production do
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer'
end
