class CreateWaMolecules < ActiveRecord::Migration
  def self.up
    create_table :molecules do |t|
      t.column :position, :integer
      t.column :page_id, :integer
      t.column :name, :string
      t.column :display_name, :string
    end
  end

  def self.down
    drop_table :molecules
  end
end
