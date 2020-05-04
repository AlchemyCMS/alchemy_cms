# frozen_string_literal: true
class RemoveSiteIdFromNodes < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :alchemy_nodes, :alchemy_sites
    remove_index :alchemy_nodes, :site_id
    remove_column :alchemy_nodes, :site_id, :integer, null: false
  end

  def down
    # This IS, in fact, reversible - but it's cumbersome to do. If someone tells me it benefits them
    # I will implement.
    raise ActiveRecord::IrreversibleMigration
  end
end
