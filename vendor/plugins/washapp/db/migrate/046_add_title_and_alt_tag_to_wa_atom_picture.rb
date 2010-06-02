class AddTitleAndAltTagToWaAtomPicture < ActiveRecord::Migration
  def self.up
    add_column :wa_atom_pictures, "title", :string, :default => ""
    add_column :wa_atom_pictures, "alt_tag", :string, :default => ""
    WaAtomPicture.reset_column_information
    WaAtomPicture.find(:all).each do |a|
      a.title = ""
      a.alt_tag = ""
      a.save
    end
  end

  def self.down
    remove_column :wa_atom_pictures, "title"
    remove_column :wa_atom_pictures, "alt_tag"
  end
end
