class CreateWaAtomSitemap < ActiveRecord::Migration
  def self.up
    create_table :wa_atom_sitemaps do |t|
      t.column :content, :string
    end

  end

  def self.down
    drop_table "wa_atom_sitemaps"
  end

end