$:.push File.expand_path("lib", __dir__)
$:.unshift File.expand_path("../lib", __dir__)

# Maintain your gem's version:
require "alchemy/liquid/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "alchemy-liquid"
  s.version = Alchemy::Liquid::VERSION
  s.authors = ["Thomas von Deyen"]
  s.email = ["alchemy@blish.cloud"]
  s.homepage = "https://alchemy-cms.com"
  s.summary = "Liquid template support for AlchemyCMS element views and page layouts."
  s.description = "Opt-in Liquid templates for AlchemyCMS element views and page layouts, resolved through the regular ActionView lookup."
  s.license = "BSD-3-Clause"

  s.files = Dir["{lib}/**/*", "LICENSE", "CHANGELOG.md", "README.md"]

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/AlchemyCMS/alchemy_cms/tree/main/liquid"
  s.metadata["changelog_uri"] = "https://github.com/AlchemyCMS/alchemy_cms/blob/main/liquid/CHANGELOG.md"

  s.add_dependency "alchemy_cms", Alchemy::Liquid::VERSION
  s.add_dependency "liquid", "~> 5.5"
end
