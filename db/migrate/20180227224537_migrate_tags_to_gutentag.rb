# frozen_string_literal: true

class MigrateTagsToGutentag < ActiveRecord::Migration[5.0]
  def up
    return if table_exists?(:gutentag_tags)

    remove_index :taggings, :taggable_id
    remove_column :taggings, :tagger_id, :integer
    remove_index :taggings, :taggable_type
    remove_column :taggings, :tagger_type, :string
    remove_index :taggings, column: [:taggable_id, :taggable_type, :context], name: 'index_taggings_on_taggable_id_and_taggable_type_and_context'
    remove_column :taggings, :context, :string, limit: 128
    if index_exists? :taggings, [:tag_id, :taggable_id, :taggable_type], unique: true, name: 'taggings_idx'
      rename_index :taggings, 'taggings_idx', 'unique_taggings'
    else
      add_index :taggings, [:taggable_type, :taggable_id, :tag_id], unique: true, name: 'unique_taggings'
    end
    if index_exists? :taggings, [:taggable_id, :taggable_type], name: 'taggings_idy'
      rename_index :taggings, 'taggings_idy', 'index_gutentag_taggings_on_taggable_id_and_taggable_type'
    else
      add_index :taggings, [:taggable_type, :taggable_id]
    end
    add_column :taggings, :updated_at, :datetime, precision: 6
    change_column_null :taggings, :tag_id, false
    change_column_null :taggings, :taggable_id, false
    change_column_null :taggings, :taggable_type, false
    change_column_null :taggings, :created_at, false, Time.current
    change_column_null :taggings, :updated_at, false, Time.current
    rename_table :taggings, :gutentag_taggings

    change_column_null :tags, :name, false
    add_index :tags, :taggings_count
    rename_table :tags, :gutentag_tags

    %i(alchemy_attachments alchemy_elements alchemy_pages alchemy_pictures).each do |table|
      if column_exists? table, :cached_tag_list
        remove_column table, :cached_tag_list
      end
    end
  end
end
