class AddLinkToAtoms::Picture < ActiveRecord::Migration
  def self.up
    add_column "atom_pictures", "link", :string, :default => ""
    Atoms::Picture.reset_column_information
    Atoms::Picture.find(:all).each do |atom|
      atom.link = ""
      atom.save
    end
    add_column "atom_pictures", "link_title", :string, :default => ""
    Atoms::Picture.reset_column_information
    Atoms::Picture.find(:all).each do |atom|
      atom.link_title = ""
      atom.save
    end
    add_column "atom_pictures", "open_link_in_new_window", :boolean, :default => false
    Atoms::Picture.reset_column_information
    Atoms::Picture.find(:all).each do |atom|
      atom.open_link_in_new_window = false
      atom.save
    end
  end

  def self.down
    remove_column "atom_pictures", "link"
    remove_column "atom_pictures", "link_title"
    remove_column "atom_pictures", "open_link_in_new_window"
  end

end
