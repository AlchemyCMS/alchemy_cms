source "http://rubygems.org"

gemspec

group :test do
	gem 'factory_girl_rails', '1.4.0'
	gem "capybara", '~> 1.1.4'
	gem 'capybara-webkit', '~> 0.8.0'

	if !ENV["CI"]
		gem "launchy"
	end
end

group :assets do
	gem 'uglifier', '>= 1.0.3'
end

group :development do
	gem 'nokogiri', '~> 1.5.10' # capybara allows nokogiri 1.6.0, but this breaks ruby 1.8.7 compatibility
	gem 'rubyzip', '0.9.9'
	if !ENV["CI"]
		gem 'debugger', :platform => :ruby_19
		gem 'ruby-debug', :platform => :ruby_18
		gem 'guard-spork'
		gem 'yard'
	end
end
