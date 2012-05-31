source "http://rubygems.org"

gemspec

#For some strange reason it's only loaded outside any group
gem 'jasmine'
gem 'jasminerice'

group :test do
  gem 'sqlite3'               if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
  gem 'mysql2'                if ENV['DB'] == 'mysql'
  gem 'pg'                    if ENV['DB'] == 'postgresql'
  gem 'rspec-rails'
  gem 'factory_girl_rails', '~> 1.7.0'
  gem "capybara"
  gem 'capybara-webkit'       unless ENV['CI']
  gem "launchy"               unless ENV['CI']
  gem "database_cleaner"
end

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'guard-spork'
  gem 'yard'
  gem 'ruby-debug19', :require => 'ruby-debug', :platform => :ruby_19
  gem 'ruby-debug', :platform => :ruby_18
  gem 'bumpy'
end
