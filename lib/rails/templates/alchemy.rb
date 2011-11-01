# This rails template installs Alchemy and all depending gems.

# Installing Alchemy Gem

gem 'alchemy_cms', '>= 2.0.rc5'
gem 'ruby-debug', :group => :development, :platform => :ruby_18
gem 'ruby-debug19', :group => :development, :platform => :ruby_19

if yes?("Use Capistrano for deployment? (y/N)")
  gem 'capistrano', :group => :development
end

run 'bundle install'
