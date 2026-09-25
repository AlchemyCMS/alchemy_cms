# frozen_string_literal: true

require_relative "lib/alchemy_api/version"

Gem::Specification.new do |gem|
  gem.name = "alchemy_api"
  gem.version = AlchemyApi::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.authors = ["Martin Meyerhoff", "Thomas von Deyen"]
  gem.email = ["alchemy@blish.cloud"]
  gem.homepage = "https://www.alchemy-cms.com"
  gem.summary = "A JSON Api for AlchemyCMS"
  gem.description = "A JSON Api for AlchemyCMS"
  gem.required_ruby_version = ">= 3.3.0"
  gem.license = "AGPL-3.0-or-later"
  gem.files = Dir[
    "{app,config,lib}/**/*",
    "LICENSE",
    "README.md"
  ]
  gem.require_paths = ["lib"]

  gem.metadata["homepage_uri"] = gem.homepage
  gem.metadata["source_code_uri"] = "https://github.com/AlchemyCMS/alchemy_cms"
  gem.metadata["changelog_uri"] = "https://github.com/AlchemyCMS/alchemy_cms/blob/main/CHANGELOG.md"

  gem.add_runtime_dependency "alchemy_cms", [">= 8.4.0.a"]
  gem.add_runtime_dependency "alba", ["~> 4.0.0"]
end
