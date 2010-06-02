class AddLinkAndLinkTitleToWaAtomTexts < ActiveRecord::Migration
  def self.up
    add_column :wa_atom_texts, :link, :string
    add_column :wa_atom_texts, :title, :string
  end

  def self.down
    remove_column :wa_atom_texts, :title
    remove_column :wa_atom_texts, :link
  end
end
