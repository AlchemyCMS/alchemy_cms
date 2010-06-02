class AddCaptionForAtoms::Picture < ActiveRecord::Migration
  def self.up
    add_column "atom_pictures", "caption", :string, :default => ""
    Atoms::Picture.reset_column_information
    Atoms::Picture.find(:all).each do |atom|
      atom.caption = ""
      atom.save
    end
  end

  def self.down
    remove_column "atom_pictures", "caption"
  end

end
