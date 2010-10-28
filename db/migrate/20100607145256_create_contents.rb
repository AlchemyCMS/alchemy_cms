class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.string :name
      t.string :essence_type
      t.integer :essence_id
      t.integer :element_id
      t.integer :position
      t.timestamps
      t.userstamps
    end
    add_index :contents, [:element_id, :position]
  end

  def self.down
    drop_table :contents
  end
end
