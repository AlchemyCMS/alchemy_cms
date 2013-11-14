source 'http://rubygems.org'

gemspec

# Remove this after the new version (1.0.2) was released https://github.com/alexspeller/non-stupid-digest-assets/pull/6
gem 'non-stupid-digest-assets', github: 'tvdeyen/non-stupid-digest-assets', branch: 'whitelist'

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
  gem 'pry'
end
