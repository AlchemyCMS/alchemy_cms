# frozen_string_literal: true
# This migration comes from alchemy (originally 20200511113603)
class AddMenuTypeToAlchemyNodes < ActiveRecord::Migration[6.0]
  class LocalNode < ActiveRecord::Base
    self.table_name = :alchemy_nodes
    acts_as_nested_set scope: :language_id

    def self.root_for(node)
      return node if node.parent_id.nil?

      root_for(node.parent)
    end
  end

  def up
    add_column :alchemy_nodes, :menu_type, :string
    LocalNode.all.each do |node|
      root = LocalNode.root_for(node)
      menu_type = root.name.parameterize.underscore
      node.update(menu_type: menu_type)
    end
    change_column_null :alchemy_nodes, :menu_type, false
  end

  def down
    remove_column :alchemy_nodes, :menu_type
  end
end
