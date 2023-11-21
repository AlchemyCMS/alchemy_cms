module Alchemy
  module Admin
    class NodeSelect < ViewComponent::Base
      delegate :alchemy, to: :helpers

      def initialize(node = nil, url: nil, placeholder: Alchemy.t(:search_node), query_params: nil)
        @node = node
        @url = url
        @placeholder = placeholder
        @query_params = query_params
      end

      def call
        content_tag("alchemy-node-select", content, attributes)
      end

      private

      def attributes
        options = {
          "allow-clear": true,
          placeholder: @placeholder,
          url: @url || alchemy.api_nodes_path
        }

        if @query_params
          options[:"query-params"] = @query_params.to_json
        end

        if @node
          selection = ActiveModelSerializers::SerializableResource.new(@node, include: :ancestors)
          options[:selection] = selection.to_json
        end

        options
      end
    end
  end
end
