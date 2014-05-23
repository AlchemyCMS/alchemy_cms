source 'http://rubygems.org'

gemspec

# For some strange reason it's only loaded outside any group
gem 'jasmine'
gem 'jasminerice'
gem 'multi_json', '1.7.2' # http://stackoverflow.com/q/16543693

# Code coverage plattform
gem 'coveralls', require: false

gem 'sqlite3'               if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
gem 'mysql2'                if ENV['DB'] == 'mysql'
gem 'pg'                    if ENV['DB'] == 'postgresql'

gem 'database_cleaner'

unless ENV['CI']
  gem 'pry'
  gem 'quiet_assets' # Mute assets loggin
  gem 'thin' # Get rid off 'Could not determine content-length of response body' Warning. Start with 'rails s thin'
end

group :test do
  unless ENV['FAST_SPECS']
    gem 'poltergeist'
    unless ENV['CI']
      gem 'launchy'
    end
  end
end

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end
