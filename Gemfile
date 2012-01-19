source "http://rubygems.org"

gemspec

gem 'tvdeyen-fleximage', :path => '../fleximage'

group :test do
	gem 'rspec-rails'
	gem 'sqlite3'
	gem 'factory_girl_rails', '1.4.0'
	gem "capybara"
	gem 'capybara-webkit', '~>0.8.0'
	gem "launchy"
	gem "database_cleaner"
	gem "fuubar" unless ENV['CI']
end

group :assets do
	gem 'uglifier', '>= 1.0.3'
end

group :development do
	if !ENV["CI"]
		gem 'ruby-debug-base19', '~> 0.11.26', :platform => :ruby_19
		gem 'linecache19', '~> 0.5.13', :platform => :ruby_19
		gem 'ruby-debug19', '~> 0.11.6', :require => 'ruby-debug', :platform => :ruby_19
		gem 'ruby-debug', :platform => :ruby_18
		gem 'guard-spork'
		gem 'yard'
	end
end
