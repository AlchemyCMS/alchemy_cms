# coding: utf-8
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alchemy/version'

Gem::Specification.new do |gem|
  gem.name                  = 'alchemy_cms'
  gem.version               = Alchemy::VERSION
  gem.platform              = Gem::Platform::RUBY
  gem.authors               = ['Thomas von Deyen', 'Robin Boening', 'Marc Schettke', 'Hendrik Mans', 'Carsten Fregin', 'Martin Meyerhoff']
  gem.email                 = ['hello@alchemy-cms.com']
  gem.homepage              = 'https://alchemy-cms.com'
  gem.summary               = 'A powerful, userfriendly and flexible CMS for Rails'
  gem.description           = 'Alchemy is a powerful, userfriendly and flexible Rails CMS.'
  gem.requirements << 'ImageMagick (libmagick), v6.6 or greater.'
  gem.required_ruby_version = '>= 2.3.0'
  gem.license               = 'BSD New'
  gem.files                 = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  gem.require_paths         = ['lib']

  gem.add_runtime_dependency 'active_model_serializers',         ['~> 0.10.0']
  gem.add_runtime_dependency 'acts_as_list',                     ['>= 0.3', '< 2']
  gem.add_runtime_dependency 'awesome_nested_set',               ['~> 3.1']
  gem.add_runtime_dependency 'cancancan',                        ['>= 2.1', '< 4.0']
  gem.add_runtime_dependency 'coffee-rails',                     ['>= 4.0', '< 6.0']
  gem.add_runtime_dependency 'dragonfly',                        ['~> 1.0', '>= 1.0.7']
  gem.add_runtime_dependency 'dragonfly_svg',                    ['~> 0.0.4']
  gem.add_runtime_dependency 'gutentag',                         ['~> 2.2', '>= 2.2.1']
  gem.add_runtime_dependency 'handlebars_assets',                ['~> 0.23']
  gem.add_runtime_dependency 'jquery-rails',                     ['~> 4.0', '>= 4.0.4']
  gem.add_runtime_dependency 'jquery-ui-rails',                  ['~> 6.0']
  gem.add_runtime_dependency 'kaminari',                         ['~> 1.1']
  gem.add_runtime_dependency 'originator',                       ['~> 3.1']
  gem.add_runtime_dependency 'non-stupid-digest-assets',         ['~> 1.0.8']
  gem.add_runtime_dependency 'rails',                            ['>= 5.2.0', '< 6.1']
  gem.add_runtime_dependency 'ransack',                          ['>= 1.8', '< 3.0']
  gem.add_runtime_dependency 'request_store',                    ['~> 1.2']
  gem.add_runtime_dependency 'responders',                       ['>= 2.0', '< 4.0']
  gem.add_runtime_dependency 'sassc-rails',                      ['~> 2.1']
  gem.add_runtime_dependency 'select2-rails',                    ['>= 3.5.9.1', '< 4.0']
  gem.add_runtime_dependency 'simple_form',                      ['>= 4.0', '< 6']
  gem.add_runtime_dependency 'sprockets',                        ['>= 3.0', '< 5']
  gem.add_runtime_dependency 'turbolinks',                       ['>= 2.5']
  gem.add_runtime_dependency 'webpacker',                        ['>= 4.0', '< 6']

  gem.add_development_dependency 'capybara',                     ['~> 3.0']
  gem.add_development_dependency 'capybara-screenshot',          ['~> 1.0']
  gem.add_development_dependency 'factory_bot_rails',            ['~> 6.0']
  gem.add_development_dependency 'puma',                         ['~> 4.0']
  gem.add_development_dependency 'rails-controller-testing',     ['~> 1.0']
  gem.add_development_dependency 'rspec-activemodel-mocks',      ['~> 1.0']
  gem.add_development_dependency 'rspec-rails',                  ['>= 4.0.0.beta2']
  gem.add_development_dependency 'simplecov',                    ['~> 0.17.1']
  gem.add_development_dependency 'webdrivers',                   ['~> 4.0']
  gem.add_development_dependency 'webmock',                      ['~> 3.3']
  gem.add_development_dependency 'shoulda-matchers',             ['~> 4.0']

  gem.post_install_message = <<-MSG
-------------------------------------------------------------
            Thank you for installing Alchemy CMS
-------------------------------------------------------------

- Complete the installation in an existing Rails application:

  $ bin/rake alchemy:install

- Complete the upgrade of an existing Alchemy installation:

  $ bin/rake alchemy:upgrade

and follow the onscreen instructions.

Need help? Try:

* https://stackoverflow.com/questions/tagged/alchemy-cms
* https://slackin.alchemy-cms.com
-------------------------------------------------------------

MSG
end
