# frozen_string_literal: true

module Alchemy
  module Ingredients
    class NodeEditor < BaseEditor
      delegate :node, :page, to: :ingredient

      def input_field(form)
        render Alchemy::Admin::NodeSelect.new(
          node,
          url: alchemy.api_nodes_path(language_id: page&.language_id, include: :ancestors),
          query_params: settings.fetch(:query_params, {})
        ) do
          form.text_field :node_id,
            value: node&.id,
            id: form_field_id(:node_id),
            class: "alchemy_selectbox full_width"
        end
      end
    end
  end
end
