source "http://rubygems.org"

gemspec

group :test do
	gem 'factory_girl_rails', '1.4.0'
	gem "capybara"
	gem 'capybara-webkit', '~>0.8.0'

	if !ENV["CI"]
		gem "launchy"
	end
end

group :assets do
	gem 'uglifier', '>= 1.0.3'
end

group :development do
	if !ENV["CI"]
		gem 'debugger', :platform => :ruby_19
		gem 'ruby-debug', :platform => :ruby_18
		gem 'guard-spork'
		gem 'yard'
	end
end
