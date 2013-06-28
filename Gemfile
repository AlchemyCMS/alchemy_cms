source 'http://rubygems.org'

gemspec

# rails 4 specific
gem 'awesome_nested_set', :github => 'collectiveidea/awesome_nested_set', :branch => 'rails4'
gem 'protected_attributes', :github => 'rails/protected_attributes'
#gem 'actionpack-action_caching', :github => 'rails/actionpack-action_caching'
#gem 'actionpack-page_caching', :github => 'rails/actionpack-page_caching'
gem 'acts-as-taggable-on', :github => 'mbleigh/acts-as-taggable-on'
gem 'acts_as_list', :github => 'tvdeyen/acts_as_list', :branch => 'ar3-find-syntax-fix'

# For some strange reason it's only loaded outside any group
#gem 'jasmine'
#gem 'jasminerice'
gem 'multi_json', '1.7.2' # http://stackoverflow.com/q/16543693

# Code coverage plattform
gem 'coveralls', require: false

group :test do
  gem 'sqlite3'               if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
  gem 'mysql2'                if ENV['DB'] == 'mysql'
  gem 'pg'                    if ENV['DB'] == 'postgresql'
  gem 'poltergeist'
  gem 'connection_pool' # https://gist.github.com/mperham/3049152
  unless ENV['CI']
    gem 'launchy'
  end
end

group :development do
  unless ENV['CI']
    gem 'debugger'
    gem 'thin' # Get rid off 'Could not determine content-length of response body' Warning. Start with 'rails s thin'
  end
end
