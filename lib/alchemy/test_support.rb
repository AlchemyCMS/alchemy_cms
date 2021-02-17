# frozen_string_literal: true

module Alchemy
  module TestSupport
    def self.factory_paths
      Dir[
        ::Alchemy::Engine.root.join("lib", "alchemy", "test_support", "factories", "*_factory.rb")
      ].map { |path| path.sub(/.rb\z/, "") }
    end
  end
end
