class CreateWaMoleculesPages < ActiveRecord::Migration
  def self.up
    create_table :molecules_pages, :id => false do |t|
      t.column :molecule_id, :integer
      t.column :page_id, :integer
    end
  end

  def self.down
    drop_table :molecules_pages
  end
end
