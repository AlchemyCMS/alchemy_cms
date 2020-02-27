# frozen_string_literal: true

module Alchemy
  VERSION = "5.0.0.a"

  def self.version
    VERSION
  end

  def self.gem_version
    Gem::Version.new(VERSION)
  end
end
