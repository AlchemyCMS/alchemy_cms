# frozen_string_literal: true

module Alchemy
  class EssenceNode < BaseRecord
    NODE_ID = /\A\d+\z/

    acts_as_essence(
      ingredient_column: :node,
      preview_text_column: :node_name,
      belongs_to: {
        class_name: "Alchemy::Node",
        foreign_key: :node_id,
        inverse_of: :essence_nodes,
        optional: true
      }
    )

    delegate :name, to: :node, prefix: true

    def ingredient=(node)
      case node
      when NODE_ID
        self.node = Alchemy::Page.new(id: node)
      when Alchemy::Node
        self.node = node
      else
        super
      end
    end
  end
end
