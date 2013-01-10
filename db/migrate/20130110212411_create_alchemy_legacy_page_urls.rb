class CreateAlchemyLegacyPageUrls < ActiveRecord::Migration
  def change
    create_table :alchemy_legacy_page_urls do |t|
      t.string  :urlname, null: false
      t.integer :page_id, null: false

      t.timestamps
    end
    add_index :alchemy_legacy_page_urls, :urlname
  end
end
