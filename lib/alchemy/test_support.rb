# frozen_string_literal: true

module Alchemy
  module TestSupport
    class << self
      def factory_paths
        Dir[
          ::Alchemy::Engine.root.join("lib", "alchemy", "test_support", "factories", "*_factory.rb")
        ].map { |path| path.sub(/.rb\z/, "") }
      end
      deprecate factory_paths: :factories_path, deprecator: Alchemy::Deprecation

      def factories_path
        ::Alchemy::Engine.root.join("lib", "alchemy", "test_support", "factories")
      end
    end
  end
end
