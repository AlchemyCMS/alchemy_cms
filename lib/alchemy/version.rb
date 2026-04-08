# frozen_string_literal: true

module Alchemy
  VERSION = "8.3.0.dev"

  def self.version
    VERSION
  end

  def self.gem_version
    Gem::Version.new(VERSION)
  end
end
