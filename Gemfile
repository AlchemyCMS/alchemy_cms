source 'http://rubygems.org'

gemspec

# rails 4 specific
gem 'rails3-jquery-autocomplete', github: 'francisd/rails3-jquery-autocomplete'

# Code coverage plattform
gem 'coveralls', require: false

group :test do
  gem 'sqlite3'               if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
  gem 'mysql2'                if ENV['DB'] == 'mysql'
  gem 'pg'                    if ENV['DB'] == 'postgresql'
  unless ENV['FAST_SPECS']
    gem 'poltergeist'
    gem 'connection_pool' # https://gist.github.com/mperham/3049152
    unless ENV['CI']
      gem 'launchy'
    end
  end
end

group :development, :test do
  unless ENV['CI']
    gem 'pry'
    gem 'bumpy'
    gem 'yard'
    gem 'redcarpet'
  end
  gem 'jasmine-rails', github: 'searls/jasmine-rails'
end
