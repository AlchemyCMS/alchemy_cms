# frozen_string_literal: true

module Alchemy
  class EssenceNode < BaseRecord
    acts_as_essence(
      ingredient_column: :node,
      preview_text_column: :node_name,
      belongs_to: {
        class_name: "Alchemy::Node",
        foreign_key: :node_id,
        inverse_of: :essence_nodes,
        optional: true,
      },
    )

    delegate :name, to: :node, prefix: true, allow_nil: true
  end
end
