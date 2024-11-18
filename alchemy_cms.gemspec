# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "alchemy/version"

Gem::Specification.new do |gem|
  gem.name = "alchemy_cms"
  gem.version = Alchemy::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.authors = ["Thomas von Deyen", "Robin Boening", "Marc Schettke", "Hendrik Mans", "Carsten Fregin", "Martin Meyerhoff"]
  gem.email = ["alchemy@blish.cloud"]
  gem.homepage = "https://alchemy-cms.com"
  gem.summary = "A powerful, userfriendly and flexible CMS for Rails"
  gem.description = "Alchemy is a powerful, userfriendly and flexible Rails CMS."
  gem.requirements << "ImageMagick (libmagick), v6.6 or greater."
  gem.required_ruby_version = ">= 3.1.0"
  gem.license = "BSD-3-Clause"
  gem.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/|bun\.lockdb|package\.json|^\.}) }
  gem.require_paths = ["lib"]

  gem.metadata["homepage_uri"] = gem.homepage
  gem.metadata["source_code_uri"] = "https://github.com/AlchemyCMS/alchemy_cms"
  gem.metadata["changelog_uri"] = "https://github.com/AlchemyCMS/alchemy_cms/blob/main/CHANGELOG.md"

  %w[
    actionmailer
    actionpack
    actionview
    activejob
    activemodel
    activerecord
    activesupport
    railties
  ].each do |rails_gem|
    gem.add_runtime_dependency rails_gem, [">= 7.0", "< 8.1"]
  end

  gem.add_runtime_dependency "active_model_serializers", ["~> 0.10.14"]
  gem.add_runtime_dependency "acts_as_list", [">= 0.3", "< 2"]
  gem.add_runtime_dependency "awesome_nested_set", ["~> 3.1", ">= 3.7.0"]
  gem.add_runtime_dependency "cancancan", [">= 2.1", "< 4.0"]
  gem.add_runtime_dependency "coffee-rails", [">= 4.0", "< 6.0"]
  gem.add_runtime_dependency "csv", ["~> 3.3"]
  gem.add_runtime_dependency "dragonfly", ["~> 1.4"]
  gem.add_runtime_dependency "dragonfly_svg", ["~> 0.0.4"]
  gem.add_runtime_dependency "gutentag", ["~> 2.2", ">= 2.2.1"]
  gem.add_runtime_dependency "importmap-rails", ["~> 1.2", ">= 1.2.1"]
  gem.add_runtime_dependency "kaminari", ["~> 1.1"]
  gem.add_runtime_dependency "originator", ["~> 3.1"]
  gem.add_runtime_dependency "ransack", ["~> 4.2", "< 5.0"]
  gem.add_runtime_dependency "simple_form", [">= 4.0", "< 6"]
  gem.add_runtime_dependency "turbo-rails", [">= 1.4", "< 2.1"]
  gem.add_runtime_dependency "view_component", ["~> 3.0"]

  gem.add_development_dependency "capybara", ["~> 3.0"]
  gem.add_development_dependency "capybara-screenshot", ["~> 1.0"]
  gem.add_development_dependency "capybara-shadowdom", ["~> 0.3"]
  gem.add_development_dependency "factory_bot_rails", ["~> 6.0"]
  gem.add_development_dependency "puma", ["~> 6.0"]
  gem.add_development_dependency "rails-controller-testing", ["~> 1.0"]
  gem.add_development_dependency "rspec-activemodel-mocks", ["~> 1.0"]
  gem.add_development_dependency "rspec-rails", ["~> 7.0"]
  gem.add_development_dependency "simplecov", ["~> 0.20"]
  gem.add_development_dependency "selenium-webdriver", ["~> 4.10"]
  gem.add_development_dependency "webmock", ["~> 3.3"]
  gem.add_development_dependency "shoulda-matchers", ["~> 6.0"]
  gem.add_development_dependency "timecop", ["~> 0.9"]

  gem.post_install_message = <<~MSG
    -------------------------------------------------------------
                Thank you for installing Alchemy CMS
    -------------------------------------------------------------

    - Complete the installation in an existing Rails application:

      $ bin/rake alchemy:install

    - Complete the upgrade of an existing Alchemy installation:

      $ bin/rake alchemy:upgrade

    and follow the onscreen instructions.

    Need help? Try:

    * https://stackoverflow.com/questions/tagged/alchemy-cms
    * https://slackin.alchemy-cms.com
    -------------------------------------------------------------

  MSG
end
