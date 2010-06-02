class AddLinkClassNameToWaAtomPictures < ActiveRecord::Migration
  def self.up
    add_column "wa_atom_pictures", "link_class_name", :string, :default => ""
    WaAtomPicture.reset_column_information
    WaAtomPicture.find(:all).each do |atom|
      atom.link_class_name = ""
      atom.save
    end
  end

  def self.down
    remove_column "wa_atom_pictures", "link_class_name"
  end
end
