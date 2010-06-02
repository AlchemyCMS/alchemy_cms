class AddCssClassToAtoms::Pictures < ActiveRecord::Migration
  def self.up
    unless Atoms::Picture.first.respond_to?(:css_class)
      add_column :atom_pictures, :css_class, :string, :default => "no_float"
    end
  end

  def self.down
    remove_column :atom_pictures, :css_class
  end
end
