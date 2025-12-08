$:.push File.expand_path("lib", __dir__)

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

  s.files = Dir["{app,locales,lib,vendor}/**/*", "CHANGELOG.md", "LICENSE", "README.md"]

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/AlchemyCMS/alchemy_i18n"
  s.metadata["changelog_uri"] = "https://github.com/AlchemyCMS/alchemy_i18n/blob/main/CHANGELOG.md"

  s.add_dependency "alchemy_cms", [">= 8.0.0.c", "< 9"]
  s.add_dependency "rails-i18n"

  s.add_development_dependency "github_changelog_generator"
end
