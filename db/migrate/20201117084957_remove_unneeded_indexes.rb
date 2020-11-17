class RemoveUnneededIndexes < ActiveRecord::Migration[6.0]
  def change
    remove_index :alchemy_languages, name: "index_alchemy_languages_on_language_code", column: :language_code
    remove_index :alchemy_sites, name: "index_alchemy_sites_on_host", column: :host
    remove_index :gutentag_taggings, name: "index_gutentag_taggings_on_taggable_type_and_taggable_id", column: [:taggable_type, :taggable_id]
  end
end
