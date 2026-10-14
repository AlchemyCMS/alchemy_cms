$:.push File.expand_path("lib", __dir__)
$:.unshift File.expand_path("../lib", __dir__)

# Maintain your gem's version:
require "alchemy_i18n/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "alchemy_i18n"
  s.version     = AlchemyI18n::VERSION
  s.authors     = ["Thomas von Deyen"]
  s.email       = ["thomas@vondeyen.com"]
  s.homepage    = "https://alchemy-cms.com"
  s.summary     = "AlchemyCMS translation files"
  s.description = "Translation files for AlchemyCMS"
  s.license     = "MIT"

  s.files = Dir[
    "{app,lib,locales}/**/*",
    "vendor/{assets,locales}/**/*",
    "CHANGELOG.md",
    "LICENSE",
    "README.md"
  ]

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/AlchemyCMS/alchemy_cms/tree/main/i18n"
  s.metadata["changelog_uri"] = "https://github.com/AlchemyCMS/alchemy_cms/blob/main/CHANGELOG.md"

  s.add_dependency "alchemy_cms", AlchemyI18n::VERSION
  s.add_dependency "rails-i18n"
end
