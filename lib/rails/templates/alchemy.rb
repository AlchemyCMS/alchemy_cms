require 'alchemy/version'
# This rails template installs Alchemy and all depending gems.

# Installing Alchemy Gem

gem 'alchemy_cms', "~> #{Alchemy::VERSION}"

if yes? "\nDo you want to install the Alchemy demo kit (from http://demo.alchemy-cms.com)? (y/N)"
  #gem 'alchemy-demo_kit'
  ENV['INSTALL_DEMO_KIT']
end

gem 'ruby-debug', :group => :development, :platform => :ruby_18
gem 'debugger', :group => :development, :platform => :ruby_19

if yes?("\nDo you want to use Capistrano for deployment? (y/N)")
  gem 'capistrano', :group => :development
end
