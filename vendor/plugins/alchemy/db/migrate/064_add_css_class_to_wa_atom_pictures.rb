class AddCssClassToWaAtomPictures < ActiveRecord::Migration
  def self.up
    unless WaAtomPicture.first.respond_to?(:css_class)
      add_column :wa_atom_pictures, :css_class, :string, :default => "no_float"
    end
  end

  def self.down
    remove_column :wa_atom_pictures, :css_class
  end
end
