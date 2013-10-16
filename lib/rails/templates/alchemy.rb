# This rails template installs Alchemy and all depending gems.
require File.expand_path('../../../alchemy/version', __FILE__)

gem 'alchemy_cms', "~> #{Alchemy::VERSION}"

if yes?("\nDo you want to use Capistrano for deployment? (y/N)")
  gem 'capistrano', group: 'development'
end
