class CreateCells < ActiveRecord::Migration
  def self.up
    create_table :cells do |t|
      t.integer :page_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :cells
  end
end
