source 'http://rubygems.org'

gemspec

# rails 4 specific
gem 'acts_as_ferret',             github: 'tvdeyen/acts_as_ferret',             branch: 'rails-4'
gem 'rails3-jquery-autocomplete', github: 'francisd/rails3-jquery-autocomplete'

# Code coverage plattform
gem 'coveralls', require: false

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
