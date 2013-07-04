source 'http://rubygems.org'

gemspec

# rails 4 specific
gem 'sqlite3'               if ENV['DB'].nil? || ENV['DB'] == 'sqlite'
gem 'rails',                            "~> 4.0.0"
gem 'devise', github: 'plataformatec/devise'
gem 'devise-encryptable',               "~> 0.1.1"
gem 'awesome_nested_set', github: 'collectiveidea/awesome_nested_set', branch: 'rails4'
gem 'acts-as-taggable-on', github: 'mbleigh/acts-as-taggable-on'
gem 'declarative_authorization',        "~> 0.5.7"
gem 'dragonfly',                        "~> 0.9.14"
gem 'kaminari',                         "~> 0.14.1"
gem 'acts_as_ferret', github: 'tvdeyen/acts_as_ferret', branch: 'rails-4'
gem 'acts_as_list', github: 'philippfranke/acts_as_list', branch: 'rails4_compatibility'
gem 'magiclabs-userstamp',              "~> 2.0.2"
gem 'dynamic_form',                     "~> 1.1"
gem 'jquery-rails',                     "~> 2.2.1"
gem 'jquery-ui-rails',                  "~> 3.0.1"
gem 'sass-rails',                       '~> 4.0.0'
gem 'uglifier',                         '>= 1.3.0'
gem 'coffee-rails',                     '~> 4.0.0'
gem 'compass-rails',                    github: 'milgner/compass-rails', branch: 'rails4'
gem 'sassy-buttons',                    '~> 0.1.3'
gem 'rails3-jquery-autocomplete',       github: 'francisd/rails3-jquery-autocomplete'
gem 'tvdeyen-handles_sortable_columns', '~> 0.1.5'

# for attr_accesible
gem 'protected_attributes', github: 'rails/protected_attributes'

# for caching and sweepers
gem 'rails-observers', github: 'rails/rails-observers'
gem 'actionpack-action_caching', github: 'rails/actionpack-action_caching'
gem 'actionpack-page_caching', github: 'rails/actionpack-page_caching'

gem 'multi_json', '1.7.2' # http://stackoverflow.com/q/16543693

# Code coverage plattform
gem 'coveralls', require: false

group :test do
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
    gem 'bumpy'
    gem 'capybara', '~> 2.0.3'
    gem 'factory_girl_rails'
    gem 'rspec-rails', '~> 2.13.1'
    gem 'yard'
    gem 'redcarpet'
  end
end
