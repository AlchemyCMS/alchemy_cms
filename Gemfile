source 'http://rubygems.org'

gemspec

#For some strange reason it's only loaded outside any group
gem 'jasmine'
gem 'jasminerice'

group :test do
  gem 'sqlite3'               if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
  gem 'mysql2'                if ENV['DB'] == 'mysql'
  gem 'pg'                    if ENV['DB'] == 'postgresql'
  gem 'poltergeist', '1.1.0'
  unless ENV['CI']
    gem 'launchy'
    gem 'simplecov', :require => false
  end
end

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  unless ENV['CI']
    gem 'guard-spork'
    #gem 'debugger'
    gem 'quiet_assets' # Mute assets loggin
    gem 'thin' # Get rid off 'Could not determine content-length of response body' Warning. Start with 'rails s thin'
  end
end
