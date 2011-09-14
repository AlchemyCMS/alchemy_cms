# This rails template installs Alchemy and all depending gems.
# Run it with +rails YOUR_APP_NAME -d mysql -m alchemy+.

# Installing Alchemy Gem

gem 'alchemy_cms', '>= 2.0.pre2'
gem 'ruby-debug', :group => :development
gem 'mongrel', :group => :development

if yes?("Use Capistrano for deployment? (y/N)")
  gem 'capistrano', :group => :development
end

run 'bundle install'
