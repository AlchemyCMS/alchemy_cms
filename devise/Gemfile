source "https://rubygems.org"

gemspec

gem 'alchemy_cms', github: 'magiclabs/alchemy_cms', branch: 'master'
gem 'pry'

# Remove this after the new version (1.0.2) was released https://github.com/alexspeller/non-stupid-digest-assets/pull/6
gem 'non-stupid-digest-assets', github: 'tvdeyen/non-stupid-digest-assets', branch: 'check-existence'

group :test do
  gem 'sqlite3' if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
  gem 'mysql2'  if ENV['DB'] == 'mysql'
  gem 'pg'      if ENV['DB'] == 'postgresql'
end

gem 'coveralls', require: false
