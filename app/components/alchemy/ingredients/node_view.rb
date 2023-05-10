module Alchemy
  module Ingredients
    class NodeView < BaseView
      delegate :node, to: :ingredient

      def call
        render(node)
      end
    end
  end
end
