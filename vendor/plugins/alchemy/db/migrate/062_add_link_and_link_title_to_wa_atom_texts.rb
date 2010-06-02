class AddLinkAndLinkTitleToWaAtomTexts < ActiveRecord::Migration
  def self.up
    add_column :atom_texts, :link, :string
    add_column :atom_texts, :title, :string
  end

  def self.down
    remove_column :atom_texts, :title
    remove_column :atom_texts, :link
  end
end
