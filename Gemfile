source "http://rubygems.org"

# Specify your gem's dependencies in alchemy.gemspec
gemspec

gem 'fleximage', :git => 'git@github.com:masche842/fleximage.git'
gem 'userstamp', :git => 'git@github.com:masche842/userstamp.git'

#gem 'attachment_magic', :path => '/Users/tvd/code/ruby/gems/attachment_magic'

group :development, :test do
	gem 'gettext', '>=1.9.3', :require => false
end

group :test do
	gem 'factory_girl_rails'
	gem "capybara"
	gem "launchy"
	gem "database_cleaner"
end
