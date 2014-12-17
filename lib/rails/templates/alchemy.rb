# This rails template installs Alchemy and all depending gems.
require File.expand_path('../../../alchemy/version', __FILE__)

gem 'alchemy_cms', "#{Alchemy::VERSION}"
gem 'alchemy-devise', github: 'magiclabs/alchemy-devise', branch: 'master'
gem 'capistrano', '~> 2.15.5', group: 'development'

run 'bundle install'
