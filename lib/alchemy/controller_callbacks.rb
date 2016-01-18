module Alchemy
  mattr_reader :controller_callbacks, instance_reader: false do
    Array.new
  end

  module ControllerCallbacks
    def run_callback(controller = controller_name, action = action_name)
      Alchemy.controller_callbacks.collect do |callback|
        callback["#{controller}.#{action}".freeze].try(:call, self)
      end
    end
  end
end
