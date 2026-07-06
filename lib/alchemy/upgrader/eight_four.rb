# frozen_string_literal: true

module Alchemy
  class Upgrader
    module EightFour
      # Alchemy does not depend on the dragonfly gem anymore.
      # Apps still using the dragonfly storage adapter need to
      # declare the gem in their own Gemfile.
      def add_dragonfly_gem
        return unless Alchemy.storage_adapter.dragonfly?

        run %(bundle add dragonfly --version "~> 1.4")
      end
    end
  end
end
