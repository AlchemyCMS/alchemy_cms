# frozen_string_literal: true

module Alchemy
  extend self

  VERSION = "8.3.4"

  def version
    VERSION
  end

  def gem_version
    Gem::Version.new(VERSION)
  end

  def git_revision_info
    source = Bundler.locked_gems.sources.find { _1.name == "alchemy_cms" }
    return unless source.respond_to?(:revision)

    {
      revision: source.revision,
      branch: source.branch
    }
  rescue
    nil
  end
end
