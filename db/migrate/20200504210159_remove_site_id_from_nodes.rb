# frozen_string_literal: true
class RemoveSiteIdFromNodes < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :alchemy_nodes, :alchemy_sites
    remove_index :alchemy_nodes, :site_id
    remove_column :alchemy_nodes, :site_id, :integer, null: false
  end

  def down
    add_column :alchemy_nodes, :site_id, :integer, null: true
    sql = <<~SQL
      UPDATE alchemy_nodes
      SET site_id = (
        SELECT alchemy_languages.site_id FROM alchemy_languages WHERE alchemy_nodes.language_id = alchemy_languages.id
      ) WHERE
      EXISTS (
        SELECT *
        FROM alchemy_languages
        WHERE alchemy_languages.id = alchemy_nodes.language_id
      );
    SQL

    connection.execute(sql)
    change_column :alchemy_nodes, :site_id, :integer, null: false
    add_index :alchemy_nodes, :site_id
    add_foreign_key :alchemy_nodes, :alchemy_sites, column: :site_id
  end
end
