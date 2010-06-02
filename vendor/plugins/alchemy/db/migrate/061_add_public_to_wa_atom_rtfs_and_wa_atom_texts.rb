class AddPublicToWaAtomRtfsAndWaAtomTexts < ActiveRecord::Migration
  def self.up
    add_column :wa_atom_rtfs, :public, :boolean
    add_column :wa_atom_texts, :public, :boolean

    WaAtomText.reset_column_information
    WaAtomText.find(:all).each do |atom|
      wa_atom = WaAtom.find_by_atom_id(atom.id)
      unless wa_atom.nil?
        mol = wa_atom.wa_molecule
        unless mol.nil?
          atom.public = mol.public?
          atom.save
        end
      end
    end

    WaAtomRtf.reset_column_information
    WaAtomRtf.find(:all).each do |atom|
      wa_atom = WaAtom.find_by_atom_id(atom.id)
      unless wa_atom.nil?
        mol = wa_atom.wa_molecule
        unless mol.nil?
          atom.public = mol.public?
          atom.save
        end
      end
    end
  end

  def self.down
    remove_column :wa_atom_texts, :do_not_index
    remove_column :wa_atom_rtfs, :do_not_index
  end
end
