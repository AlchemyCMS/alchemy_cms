module Alchemy
  module Auth
    module Engine
      def self.get_instance
        ::Authorization::Engine.instance
      end
    end
  end
end
