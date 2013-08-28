source 'http://rubygems.org'

gemspec

# rails 4 specific
gem 'rails3-jquery-autocomplete', github: 'francisd/rails3-jquery-autocomplete'

# Code coverage plattform
gem 'coveralls', require: false

# Fixes
# - http://stackoverflow.com/questions/18394817/json-error-with-coffeescript-rails-asset-pipeline
# - https://github.com/sstephenson/execjs/issues/129
gem 'multi_json', '1.7.8'

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

group :development do
  unless ENV['CI']
    gem 'debugger'
    gem 'bumpy'
    gem 'yard'
    gem 'redcarpet'
  end
end

group :development, :test do
  gem 'jasmine-rails', github: 'searls/jasmine-rails'
end
