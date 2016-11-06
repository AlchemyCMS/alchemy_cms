# This migration comes from alchemy (originally 20160927205604)
class AddForeignKeyIndicesAndNullConstraints < ActiveRecord::Migration
  def change
    change_column_null :alchemy_cells, :page_id, false, 0
    change_column_null :alchemy_contents, :element_id, false, 0
    change_column_null :alchemy_contents, :essence_id, false, 0
    change_column_null :alchemy_contents, :essence_type, false, 'Alchemy::EssenceText'
    change_column_null :alchemy_elements, :page_id, false, 0
    change_column_null :alchemy_folded_pages, :page_id, false, 0
    change_column_null :alchemy_folded_pages, :user_id, false, 0
    change_column_null :alchemy_languages, :site_id, false, 0

    add_index :alchemy_cells, :page_id
    add_index :alchemy_contents, [:essence_id, :essence_type], unique: true
    add_index :alchemy_elements, :cell_id
    add_index :alchemy_essence_files, :attachment_id
    add_index :alchemy_essence_pictures, :picture_id
    add_index :alchemy_folded_pages, [:page_id, :user_id], unique: true
    add_index :alchemy_legacy_page_urls, :page_id
  end
end
