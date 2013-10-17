# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "alchemy/version"

Gem::Specification.new do |s|
  s.name                  = "alchemy_cms"
  s.version               = Alchemy::VERSION
  s.platform              = Gem::Platform::RUBY
  s.authors               = ["Thomas von Deyen", "Robin Boening", "Marc Schettke", "Hendrik Mans", "Carsten Fregin"]
  s.email                 = ["alchemy@magiclabs.de"]
  s.homepage              = "http://alchemy-cms.com"
  s.summary               = %q{A powerful, userfriendly and flexible CMS for Rails 3}
  s.description           = %q{Alchemy is a powerful, userfriendly and flexible Rails 3 CMS.}
  s.requirements         << 'ImageMagick (libmagick), v6.6 or greater.'
  s.required_ruby_version = '>= 1.9.3'
  s.license               = 'BSD New'
  s.post_install_message  = <<-POST_INSTALL

 If you are installing Alchemy the first time
 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  $ bundle exec rake alchemy:install


 If you are upgrading an existing Alchemy installation
 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  $ bundle exec rake alchemy:upgrade

POST_INSTALL

  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths         = ["lib"]

  s.add_runtime_dependency %q<rails>,                            ["~> 3.2.13"]
  s.add_runtime_dependency %q<awesome_nested_set>,               ["~> 2.0"]
  s.add_runtime_dependency %q<acts-as-taggable-on>,              ["~> 2.1"]
  s.add_runtime_dependency %q<declarative_authorization>,        ["~> 0.5.7"]
  s.add_runtime_dependency %q<dragonfly>,                        ["~> 0.9.14"]
  s.add_runtime_dependency %q<kaminari>,                         ["~> 0.14.1"]
  s.add_runtime_dependency %q<acts_as_ferret>,                   ["~> 0.5"]
  s.add_runtime_dependency %q<acts_as_list>,                     ["~> 0.2.0"]
  s.add_runtime_dependency %q<magiclabs-userstamp>,              ["~> 2.0.2"]
  s.add_runtime_dependency %q<dynamic_form>,                     ["~> 1.1"]
  s.add_runtime_dependency %q<jquery-rails>,                     ["~> 3.0.4"]
  s.add_runtime_dependency %q<jquery-ui-rails>,                  ["~> 3.0.1"]
  s.add_runtime_dependency %q<sass-rails>,                       ['~> 3.2.3']
  s.add_runtime_dependency %q<coffee-rails>,                     ['~> 3.2.1']
  s.add_runtime_dependency %q<compass-rails>,                    ['~> 1.0.3']
  s.add_runtime_dependency %q<sassy-buttons>,                    ['~> 0.1.3']
  s.add_runtime_dependency %q<rails3-jquery-autocomplete>,       ['~> 1.0.10']
  s.add_runtime_dependency %q<tvdeyen-handles_sortable_columns>, ['~> 0.1.5']
  s.add_runtime_dependency %q<spinner.rb>

  s.add_development_dependency %q<bumpy>
  s.add_development_dependency %q<capybara>,               ['~> 2.0.3']
  s.add_development_dependency %q<factory_girl_rails>
  s.add_development_dependency %q<rspec-rails>,            ['~> 2.13.1']
  s.add_development_dependency %q<sqlite3>
  s.add_development_dependency %q<yard>
  s.add_development_dependency %q<redcarpet>

end
