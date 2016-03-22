$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "alchemy/devise/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "alchemy-devise"
  s.version     = Alchemy::Devise::VERSION
  s.authors     = ["Thomas von Deyen"]
  s.email       = ["tvd@magiclabs.de"]
  s.homepage    = "http://alchemy-cms.com"
  s.summary     = "Devise based user authentication for Alchemy CMS."
  s.description = "Devise based user authentication for Alchemy CMS."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "alchemy_cms", ["> 3.2", "< 4.0"]
  s.add_dependency "devise",      [">= 3.5.4", "< 4.0"]

  s.add_development_dependency "capybara"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "rspec-activemodel-mocks", "~> 1.0"
  s.add_development_dependency "rspec-rails",             "~> 3.1"

  s.post_install_message =<<-MSG
In order to complete the installation or the upgrade of Alchemy::Devise run:

  $ bin/rails g alchemy:devise:install

NOTE: If you are upgrading from Alchemy::Devise 2.0 or older and have overwritten the mailer views, you need to upgrade them!
See: https://github.com/plataformatec/devise/blob/master/CHANGELOG.md#310---2013-09-05

  MSG
end
