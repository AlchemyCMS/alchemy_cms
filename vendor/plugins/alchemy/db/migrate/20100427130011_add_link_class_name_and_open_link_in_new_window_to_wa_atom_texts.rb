class AddLinkClassNameAndOpenLinkInNewWindowToWaAtomTexts < ActiveRecord::Migration
  def self.up
    add_column :atom_texts, :link_class_name, :string
    add_column :atom_texts, :open_link_in_new_window, :boolean, :default => false
  end

  def self.down
    remove_column :atom_texts, :open_link_in_new_window
    remove_column :atom_texts, :link_class_name
  end
end
