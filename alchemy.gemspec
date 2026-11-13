# frozen_string_literal: true

require_relative "lib/alchemy/version"

Gem::Specification.new do |s|
  s.name = "alchemy"
  s.version = Alchemy::VERSION
  s.summary = "Alchemy - the Rails CMS framework"
  s.description = <<~DESC
    Installs Alchemy CMS composed out of alchemy_cms, alchemy-devise and alchemy_i18n gems.

    Versions 1.0.x (2013) were the unrelated UI Alchemy asset library.

    Pin `gem "alchemy", "~> 1.0"` if you still want to use the 2013 UI Alchemy assets.
  DESC
  s.authors = ["Thomas von Deyen"]
  s.homepage = "https://www.alchemy-cms.com"
  s.license = "BSD-3-Clause"
  s.required_ruby_version = ">= 3.1.0"
  s.files = ["lib/alchemy.rb", "README.md", "LICENSE"]

  s.add_dependency "alchemy_cms", s.version.to_s
  s.add_dependency "alchemy-devise", "~> #{s.version}"
  s.add_dependency "alchemy_i18n", "~> #{s.version}"

  s.post_install_message = <<~MSG
    The `alchemy` gem now installs Alchemy CMS.
    Looking for the 2013 UI Alchemy assets? Pin `gem "alchemy", "~> 1.0"`.
  MSG

  s.metadata = {
    "homepage_uri" => s.homepage,
    "source_code_uri" => "https://github.com/AlchemyCMS/alchemy_cms",
    "rubygems_mfa_required" => "true",
    "changelog_uri" => "https://github.com/AlchemyCMS/alchemy_cms/blob/main/CHANGELOG.md"
  }
end
