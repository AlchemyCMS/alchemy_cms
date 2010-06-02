class AddTitleAndAltTagToAtoms::Picture < ActiveRecord::Migration
  def self.up
    add_column :atom_pictures, "title", :string, :default => ""
    add_column :atom_pictures, "alt_tag", :string, :default => ""
    Atoms::Picture.reset_column_information
    Atoms::Picture.find(:all).each do |a|
      a.title = ""
      a.alt_tag = ""
      a.save
    end
  end

  def self.down
    remove_column :atom_pictures, "title"
    remove_column :atom_pictures, "alt_tag"
  end
end
