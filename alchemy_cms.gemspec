# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alchemy/version'

Gem::Specification.new do |gem|
  gem.name                  = 'alchemy_cms'
  gem.version               = Alchemy::VERSION
  gem.platform              = Gem::Platform::RUBY
  gem.authors               = ['Thomas von Deyen', 'Robin Boening', 'Marc Schettke', 'Hendrik Mans', 'Carsten Fregin', 'Martin Meyerhoff']
  gem.email                 = ['alchemy@magiclabs.de']
  gem.homepage              = 'https://alchemy-cms.com'
  gem.summary               = 'A powerful, userfriendly and flexible CMS for Rails 4'
  gem.description           = 'Alchemy is a powerful, userfriendly and flexible Rails 4 CMS.'
  gem.requirements << 'ImageMagick (libmagick), v6.6 or greater.'
  gem.required_ruby_version = '>= 2.0.0'
  gem.license               = 'BSD New'
  gem.files                 = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  gem.executables           = 'alchemy'
  gem.require_paths         = ['lib']

  gem.add_runtime_dependency 'actionpack-page_caching',          ['~> 1.0.0']
  gem.add_runtime_dependency 'active_model_serializers',         ['~> 0.9.0']
  gem.add_runtime_dependency 'acts_as_list',                     ['~> 0.3']
  gem.add_runtime_dependency 'acts-as-taggable-on',              ['~> 3.1']
  gem.add_runtime_dependency 'awesome_nested_set',               ['~> 3.0.0']
  gem.add_runtime_dependency 'bourbon',                          ['~> 4.2']
  gem.add_runtime_dependency 'cancancan',                        ['~> 1.9']
  gem.add_runtime_dependency 'coffee-rails',                     ['~> 4.0']
  gem.add_runtime_dependency 'dragonfly',                        ['~> 1.0.1']
  gem.add_runtime_dependency 'dragonfly_svg',                    ['~> 0.0.4']
  gem.add_runtime_dependency 'jquery-rails',                     ['~> 4.0']
  gem.add_runtime_dependency 'jquery-ui-rails',                  ['~> 5.0.0']
  gem.add_runtime_dependency 'kaminari',                         ['~> 0.15']
  gem.add_runtime_dependency 'magiclabs-userstamp',              ['~> 2.1.0']
  gem.add_runtime_dependency 'non-stupid-digest-assets',         ['~> 1.0.8']
  gem.add_runtime_dependency 'rails',                            ['>= 4.2.0', '< 5.0']
  gem.add_runtime_dependency 'ransack',                          ['~> 1.4']
  gem.add_runtime_dependency 'request_store',                    ['~> 1.2']
  gem.add_runtime_dependency 'responders',                       ['~> 2.0']
  gem.add_runtime_dependency 'select2-rails',                    ['>= 3.5.9.1', '< 4.0']
  gem.add_runtime_dependency 'simple_form',                      ['~> 3.0']
  gem.add_runtime_dependency 'turbolinks',                       ['~> 2.5']

  gem.post_install_message = <<-MSG
-------------------------------------------------------------
            Thank you for installing Alchemy CMS
-------------------------------------------------------------

- Create a new standalone Alchemy project:

  $ alchemy new my_project_name

- Complete the installation in an existing Rails application:

  $ bin/rake alchemy:install

- Complete the upgrade of an existing Alchemy installation:

  $ bin/rake alchemy:upgrade

and follow the onscreen instructions.

Need help? Try:

* http://stackoverflow.com/questions/tagged/alchemy-cms
* http://groups.google.com/group/alchemy-cms
* irc://irc.freenode.net#alchemy_cms
-------------------------------------------------------------

MSG
end
