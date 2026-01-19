# frozen_string_literal: true

module Alchemy
  VERSION = "8.0.3"

  def self.version
    VERSION
  end

  def self.gem_version
    Gem::Version.new(VERSION)
  end
end
