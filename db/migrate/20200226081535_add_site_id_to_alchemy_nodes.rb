# frozen_string_literal: true

class AddSiteIdToAlchemyNodes < ActiveRecord::Migration[5.0]
  def change
    add_column :alchemy_nodes, :site_id, :integer, index: true
    add_index :alchemy_nodes, :site_id
    reversible do |dir|
      dir.up do
        Alchemy::Node.update_all(site_id: Alchemy::Site.first&.id)
        change_column_null :alchemy_nodes, :site_id, false
      end
    end
    add_foreign_key :alchemy_nodes, :alchemy_sites, column: :site_id, on_delete: :cascade
  end
end
