source "http://rubygems.org"

gemspec

group :test do
	gem 'factory_girl_rails', '~> 1.4'
	gem "capybara"
	gem 'capybara-webkit'
	gem "launchy"
	gem "database_cleaner"
	gem "fuubar"
end

group :assets do
	gem 'sass-rails', '~> 3.1.4'
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
