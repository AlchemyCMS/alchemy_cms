module Alchemy
  module TestSupport
    # Allows you to stub the Alchemy configuration in your specs
    #
    # Require and include this file in your RSpec config.
    #
    #     RSpec.configure do |config|
    #       config.include Alchemy::TestSupport::ConfigStubbing
    #     end
    #
    module ConfigStubbing
      # Stub a key from the Alchemy config
      #
      # @param key [Symbol] The configuration key you want to stub
      # @param value [Object] The value you want to return instead of the original one
      #
      def stub_alchemy_config(key, value)
        allow(Alchemy::Config).to receive(:get) do |arg|
          if arg == key
            value
          else
            Alchemy::Config.show[arg.to_s]
          end
        end
      end
    end
  end
end
