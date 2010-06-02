class AddCaptionForWaAtomPicture < ActiveRecord::Migration
  def self.up
    add_column "wa_atom_pictures", "caption", :string, :default => ""
    WaAtomPicture.reset_column_information
    WaAtomPicture.find(:all).each do |atom|
      atom.caption = ""
      atom.save
    end
  end

  def self.down
    remove_column "wa_atom_pictures", "caption"
  end

end
