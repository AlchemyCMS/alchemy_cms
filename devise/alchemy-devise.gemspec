$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "alchemy/devise/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "alchemy-devise"
  s.version     = Alchemy::Devise::VERSION
  s.authors     = ["Thomas von Deyen"]
  s.email       = ["thomas@vondeyen.com"]
  s.homepage    = "http://alchemy-cms.com"
  s.summary     = "Devise based user authentication for AlchemyCMS."
  s.description = "Devise based user authentication for AlchemyCMS."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.add_dependency "alchemy_cms", [">= 5.0.0", "< 6.1"]
  s.add_dependency "devise",      [">= 4.7.1", "< 5"]

  s.add_development_dependency "capybara"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "rails-controller-testing"
  s.add_development_dependency "rspec-activemodel-mocks", "~> 1.0"
  s.add_development_dependency "rspec-rails",             "~> 4.0.0.beta2"
  s.add_development_dependency "simplecov"

  s.post_install_message =<<-MSG
In order to complete the installation or the upgrade of Alchemy::Devise run:

  $ bin/rails g alchemy:devise:install

MSG
end
