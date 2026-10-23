$:.push File.expand_path("../lib", __FILE__)
$:.unshift File.expand_path("../lib", __dir__)

# Maintain your gem's version:
require "alchemy/devise/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "alchemy-devise"
  s.version = Alchemy::Devise::VERSION
  s.authors = ["Thomas von Deyen"]
  s.email = ["thomas@vondeyen.com"]
  s.homepage = "https://alchemy-cms.com"
  s.summary = "Devise based user authentication for AlchemyCMS."
  s.description = "Devise based user authentication for AlchemyCMS."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "CHANGELOG.md", "README.md"]

  s.add_dependency "alchemy_cms", Alchemy::Devise::VERSION
  s.add_dependency "devise", ">= 4.9", "< 6.0"
  s.add_dependency "flickwerk", ["~> 0.3.6"]

  s.post_install_message = <<~MSG
    In order to complete the installation or the upgrade of Alchemy::Devise run:

      $ bin/rails g alchemy:devise:install

  MSG
end
