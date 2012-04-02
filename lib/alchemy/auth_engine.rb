module Alchemy
  module AuthEngine
    def self.get_instance
      Authorization::Engine.instance
    end
  end
end
