class CreateFoldedPages < ActiveRecord::Migration
  def self.up
    return if table_exists?(:folded_pages)
    create_table :folded_pages do |t|
      t.integer :page_id
      t.integer :user_id
      t.boolean :folded, :default => false
    end
  end

  def self.down
    drop_table :folded_pages
  end
end
