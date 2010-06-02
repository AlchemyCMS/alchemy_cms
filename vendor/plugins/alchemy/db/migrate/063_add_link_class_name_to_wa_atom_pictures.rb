class AddLinkClassNameToAtoms::Pictures < ActiveRecord::Migration
  def self.up
    add_column "atom_pictures", "link_class_name", :string, :default => ""
    Atoms::Picture.reset_column_information
    Atoms::Picture.find(:all).each do |atom|
      atom.link_class_name = ""
      atom.save
    end
  end

  def self.down
    remove_column "atom_pictures", "link_class_name"
  end
end
