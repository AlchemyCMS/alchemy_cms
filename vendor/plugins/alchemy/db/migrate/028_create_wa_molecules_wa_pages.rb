class CreateWaMoleculesWaPages < ActiveRecord::Migration
  def self.up
    create_table :wa_molecules_wa_pages, :id => false do |t|
      t.column :wa_molecule_id, :integer
      t.column :wa_page_id, :integer
    end
  end

  def self.down
    drop_table :wa_molecules_wa_pages
  end
end
