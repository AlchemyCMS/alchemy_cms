class AddTitleAndCssClassToWaAtomFiles < ActiveRecord::Migration
  def self.up
    add_column :atom_files, :title, :string
    add_column :atom_files, :css_class, :string, :default => "no_float"
  end

  def self.down
    remove_column :atom_files, :title
    remove_column :atom_files, :css_class
  end
end
