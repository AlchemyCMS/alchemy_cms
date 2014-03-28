# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'alchemy/version'

Gem::Specification.new do |gem|
  gem.name                  = 'alchemy_cms'
  gem.version               = Alchemy::VERSION
  gem.platform              = Gem::Platform::RUBY
  gem.authors               = ['Thomas von Deyen', 'Robin Boening', 'Marc Schettke', 'Hendrik Mans', 'Carsten Fregin']
  gem.email                 = ['alchemy@magiclabs.de']
  gem.homepage              = 'http://alchemy-cms.com'
  gem.summary               = 'A powerful, userfriendly and flexible CMS for Rails 4'
  gem.description           = 'Alchemy is a powerful, userfriendly and flexible Rails 4 CMS.'
  gem.requirements         << 'ImageMagick (libmagick), v6.6 or greater.'
  gem.required_ruby_version = '>= 1.9.3'
  gem.license               = 'BSD New'
  gem.files                 = `git ls-files`.split("\n")
  gem.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables           = 'alchemy'
  gem.require_paths         = ['lib']

  gem.add_runtime_dependency 'rails',                            '>= 4.0', '< 5.0'
  gem.add_runtime_dependency 'actionpack-page_caching',          '~> 1.0.0'
  gem.add_runtime_dependency 'awesome_nested_set',               '~> 3.0.0.rc.2'
  gem.add_runtime_dependency 'acts-as-taggable-on',              '~> 3.0.0'
  gem.add_runtime_dependency 'cancan',                           '~> 1.6.10'
  gem.add_runtime_dependency 'dragonfly',                        '~> 1.0.1'
  gem.add_runtime_dependency 'kaminari',                         '~> 0.15.0'
  gem.add_runtime_dependency 'acts_as_list',                     '~> 0.3.0'
  gem.add_runtime_dependency 'magiclabs-userstamp',              '~> 2.1.0'
  gem.add_runtime_dependency 'simple_form',                      '~> 3.0.1'
  gem.add_runtime_dependency 'jquery-rails',                     '~> 3.1.0'
  gem.add_runtime_dependency 'jquery-ui-rails',                  '~> 4.1.1'
  gem.add_runtime_dependency 'sass-rails',                       '~> 4.0.2'
  gem.add_runtime_dependency 'uglifier',                         '>= 1.3.0'
  gem.add_runtime_dependency 'coffee-rails',                     '~> 4.0.0'
  gem.add_runtime_dependency 'compass-rails',                    '~> 1.1.2'
  gem.add_runtime_dependency 'sassy-buttons',                    '~> 0.2.6'
  gem.add_runtime_dependency 'select2-rails',                    '~> 3.4'
  gem.add_runtime_dependency 'tvdeyen-handles_sortable_columns', '~> 0.1.5'
  gem.add_runtime_dependency 'spinner.rb'
  gem.add_runtime_dependency 'turbolinks',                       '~> 2.0'
  gem.add_runtime_dependency 'non-stupid-digest-assets',         '~> 1.0.3'
  gem.add_runtime_dependency 'active_model_serializers',         '~> 0.8.1'

  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'capybara'
  gem.add_development_dependency 'factory_girl_rails'

  gem.post_install_message =<<-MSG
To complete the installation of Alchemy please run:

$ bin/rake alchemy:install

To upgrade former Alchemy intallations please run:

$ bin/rake alchemy:upgrade

Thanks for installing Alchemy!

Need help?
Try https://groups.google.com/forum/#!forum/alchemy-cms
or #alchemy_cms on irc.freenode.net
MSG
end
