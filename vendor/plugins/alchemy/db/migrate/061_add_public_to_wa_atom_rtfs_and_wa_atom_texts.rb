class AddPublicToWaAtomRtfsAndWaAtomTexts < ActiveRecord::Migration
  def self.up
    add_column :atom_rtfs, :public, :boolean
    add_column :atom_texts, :public, :boolean

    WaAtomText.reset_column_information
    WaAtomText.find(:all).each do |atom|
      atom = Atom.find_by_atom_id(atom.id)
      unless atom.nil?
        mol = atom.molecule
        unless mol.nil?
          atom.public = mol.public?
          atom.save
        end
      end
    end

    WaAtomRtf.reset_column_information
    WaAtomRtf.find(:all).each do |atom|
      atom = Atom.find_by_atom_id(atom.id)
      unless atom.nil?
        mol = atom.molecule
        unless mol.nil?
          atom.public = mol.public?
          atom.save
        end
      end
    end
  end

  def self.down
    remove_column :atom_texts, :do_not_index
    remove_column :atom_rtfs, :do_not_index
  end
end
