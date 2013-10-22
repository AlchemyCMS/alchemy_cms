source "https://rubygems.org"

gemspec

gem 'alchemy_cms', github: 'magiclabs/alchemy_cms', branch: 'master'
gem 'rails3-jquery-autocomplete', github: 'francisd/rails3-jquery-autocomplete'
gem 'pry'
gem 'simplecov', :require => false, :group => :test

group :test do
  gem 'sqlite3' if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
  gem 'mysql2'  if ENV['DB'] == 'mysql'
  gem 'pg'      if ENV['DB'] == 'postgresql'
end
