source "http://rubygems.org"

# Specify your gem's dependencies in alchemy.gemspec
gemspec

group :development, :test do
  gem 'gettext', '~>2.0', :git => 'git://github.com/cameel/gettext.git', :require => false
	gem "rspec-rails", ">= 2.0.0.beta"
end

group :test do
	gem 'factory_girl_rails'
	gem "capybara", ">= 0.4.0"
	gem "sqlite3"
	gem "database_cleaner"
end
