source 'https://rubygems.org'

gemspec

gem 'sqlite3' if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
gem 'mysql2'  if ENV['DB'] == 'mysql'
gem 'pg'      if ENV['DB'] == 'postgresql'

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
end

# We need this if we want to start the dummy app in production, ie on Teatro.io
group :production do
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer'
end
