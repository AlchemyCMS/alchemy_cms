source "http://rubygems.org"

# Specify your gem's dependencies in alchemy.gemspec
gemspec

# gem 'tvdeyen-fleximage', :git => 'git@github.com:masche842/fleximage.git'
# gem 'userstamp', :git => 'git@github.com:masche842/userstamp.git'

gem 'declarative_authorization', :git => 'git://github.com/stffn/declarative_authorization.git'

group :development, :test do
	gem 'gettext', '>=1.9.3', :require => false
end

group :test do
	gem 'factory_girl_rails'
	gem "capybara"
	gem "launchy"
	gem "database_cleaner"
	gem "fuubar"
end

group :assets do
	gem 'sass-rails', '~> 3.1.4'
	gem 'uglifier', '>= 1.0.3'
end
