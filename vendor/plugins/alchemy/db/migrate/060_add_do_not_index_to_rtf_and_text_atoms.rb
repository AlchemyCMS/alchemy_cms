class AddDoNotIndexToRtfAndTextAtoms < ActiveRecord::Migration
  def self.up
    add_column :wa_atom_rtfs, :do_not_index, :boolean, :default => false
    add_column :wa_atom_texts, :do_not_index, :boolean, :default => false

    WaAtomText.reset_column_information
    WaAtomText.find(:all).each do |atom|
      atom.do_not_index = false
      atom.save
    end

    WaAtomRtf.reset_column_information
    WaAtomRtf.find(:all).each do |atom|
      atom.do_not_index = false
      atom.save
    end
  end

  def self.down
    remove_column :wa_atom_texts, :do_not_index
    remove_column :wa_atom_rtfs, :do_not_index
  end
end
