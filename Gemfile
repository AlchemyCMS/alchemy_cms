source 'http://rubygems.org'

gemspec

# rails 4 specific
gem 'acts_as_ferret',             github: 'tvdeyen/acts_as_ferret',             branch: 'rails-4'
gem 'acts_as_list',               github: 'swanandp/acts_as_list'
gem 'rails3-jquery-autocomplete', github: 'francisd/rails3-jquery-autocomplete'

# for caching and sweepers
gem 'rails-observers',            github: 'rails/rails-observers'
gem 'actionpack-action_caching',  github: 'rails/actionpack-action_caching'
gem 'actionpack-page_caching',    github: 'rails/actionpack-page_caching'

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
    gem 'bumpy'
    gem 'yard'
    gem 'redcarpet'
  end
end
