# frozen_string_literal: true

module Alchemy
  module TestSupport
    def self.factories_path
      ::Alchemy::Engine.root.join("lib", "alchemy", "test_support", "factories")
    end
  end
end
