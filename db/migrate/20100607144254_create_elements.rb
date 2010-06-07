class CreateElements < ActiveRecord::Migration
  def self.up
    create_table :elements do |t|
      t.string :name
      t.string :display_name
      t.integer :position
      t.integer :page_id
      t.boolean :public, :default => true
      t.boolean :folded, :default => false
      t.boolean :unique, :default => false
      t.timestamps
      t.userstamps
    end
    add_index :elements, [:page_id, :position]
  end

  def self.down
    drop_table :elements
  end
end
