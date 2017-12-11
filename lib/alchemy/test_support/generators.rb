module Alchemy
  module TestSupport
    module Generators
      # Tell the generator where to put its output (what it thinks of as Rails.root)
      def set_default_destination
        destination File.expand_path("../../../tmp", __FILE__)
      end

      def setup_default_destination
        set_default_destination
        before { prepare_destination }
      end
    end
  end
end
