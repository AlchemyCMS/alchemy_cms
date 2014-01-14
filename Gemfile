source 'http://rubygems.org'

gemspec

if ENV['RAILS_VERSION']
  gem 'rails', ENV['RAILS_VERSION']
end

# Remove this after the new version (1.0.3) was released https://github.com/alexspeller/non-stupid-digest-assets/
gem 'non-stupid-digest-assets', github: 'alexspeller/non-stupid-digest-assets', branch: 'master'

# Code coverage plattform
gem 'coveralls', require: false

# Fixes issues with wrong exit codes. See: https://github.com/colszowka/simplecov/issues/269
gem 'simplecov', '0.7.1'

group :test do
  gem 'sqlite3'               if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
  gem 'mysql2'                if ENV['DB'] == 'mysql'
  gem 'pg'                    if ENV['DB'] == 'postgresql'
  gem 'poltergeist'
  gem 'connection_pool' # https://gist.github.com/mperham/3049152
  unless ENV['CI']
    gem 'launchy'
  end
end

group :development, :test do
  unless ENV['CI']
    gem 'annotate'
    gem 'pry'
    gem 'bumpy'
    gem 'yard'
    gem 'redcarpet'
    gem 'pry-rails'
    gem 'spring', '~> 1.1.0.beta2'
    gem 'spring-commands-rspec'
  end
  gem 'jasmine-rails', github: 'searls/jasmine-rails'
  gem 'jasmine-jquery-rails', github: 'travisjeffery/jasmine-jquery-rails'
end
