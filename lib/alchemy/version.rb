# frozen_string_literal: true

module Alchemy
  VERSION = "4.3.2"

  def self.version
    VERSION
  end

  def self.gem_version
    Gem::Version.new(VERSION)
  end
end
