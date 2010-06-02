class AddLinkToWaAtomPicture < ActiveRecord::Migration
  def self.up
    add_column "wa_atom_pictures", "link", :string, :default => ""
    WaAtomPicture.reset_column_information
    WaAtomPicture.find(:all).each do |atom|
      atom.link = ""
      atom.save
    end
    add_column "wa_atom_pictures", "link_title", :string, :default => ""
    WaAtomPicture.reset_column_information
    WaAtomPicture.find(:all).each do |atom|
      atom.link_title = ""
      atom.save
    end
    add_column "wa_atom_pictures", "open_link_in_new_window", :boolean, :default => false
    WaAtomPicture.reset_column_information
    WaAtomPicture.find(:all).each do |atom|
      atom.open_link_in_new_window = false
      atom.save
    end
  end

  def self.down
    remove_column "wa_atom_pictures", "link"
    remove_column "wa_atom_pictures", "link_title"
    remove_column "wa_atom_pictures", "open_link_in_new_window"
  end

end
