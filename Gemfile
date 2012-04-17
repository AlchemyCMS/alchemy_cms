source "http://rubygems.org"

gemspec

#For some strange reason it's only loaded outside any group
gem 'jasmine'
gem 'jasminerice'

group :test do
  gem 'rspec-rails'
  gem 'sqlite3'
  gem 'factory_girl_rails', '1.4.0'
  gem "capybara"
  gem 'capybara-webkit', '~>0.8.0'
  gem "launchy"
  gem "database_cleaner"
  gem "fuubar"
  # gem 'ruby-debug-base19', '~> 0.11.26', :platform => :ruby_19
  # gem 'linecache19', '~> 0.5.13', :platform => :ruby_19
  # gem 'ruby-debug19', '~> 0.11.6', :require => 'ruby-debug', :platform => :ruby_19
end

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'guard-spork'
  gem 'yard'
end