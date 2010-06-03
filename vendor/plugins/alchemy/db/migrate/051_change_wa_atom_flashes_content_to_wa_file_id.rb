class ChangeWaAtomFlashesContentToWaFileId < ActiveRecord::Migration
  def self.up
    remove_column :wa_atom_flashes, :content
    add_column :wa_atom_flashes, :wa_file_id, :integer
  end

  def self.down
    add_column :wa_atom_flashes, :content, :string
    remove_column :wa_atom_flashes, :wa_file_id
  end

end
