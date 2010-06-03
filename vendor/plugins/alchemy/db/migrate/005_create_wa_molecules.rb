class CreateWaMolecules < ActiveRecord::Migration
  def self.up
    create_table :wa_molecules do |t|
      t.column :position, :integer
      t.column :wa_page_id, :integer
      t.column :name, :string
      t.column :display_name, :string
    end
  end

  def self.down
    drop_table :wa_molecules
  end
end
