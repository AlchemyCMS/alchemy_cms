require 'alchemy/version'
# This rails template installs Alchemy and all depending gems.

# Installing Alchemy Gem

gem 'alchemy_cms', "~> #{Alchemy::VERSION}"
gem 'ruby-debug', :group => :development, :platform => :ruby_18
gem 'ruby-debug19', :group => :development, :platform => :ruby_19

if yes?("\nDo you want to use Capistrano for deployment? (y/N)")
	gem 'capistrano', :group => :development
end

run 'bundle install'
