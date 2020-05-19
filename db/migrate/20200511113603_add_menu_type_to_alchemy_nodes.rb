# frozen_string_literal: true
class AddMenuTypeToAlchemyNodes < ActiveRecord::Migration[5.2]
  class LocalNode < ActiveRecord::Base
    self.table_name = :alchemy_nodes
    acts_as_nested_set scope: :language_id

    def self.root_for(node)
      return node if node.parent_id.nil?

      root_for(node.parent)
    end
  end

  def change
    add_column :alchemy_nodes, :menu_type, :string
    LocalNode.all.each do |node|
      root = LocalNode.root_for(node)
      menu_type = root.name.parameterize.underscore
      node.update(menu_type: menu_type)
    end
    change_column :alchemy_nodes, :menu_type, :string, null: false
  end
end
