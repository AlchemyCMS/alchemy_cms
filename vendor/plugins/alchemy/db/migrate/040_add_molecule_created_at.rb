class AddMoleculeCreatedAt < ActiveRecord::Migration
  def self.up
    add_column "wa_molecules", "created_at", :datetime
    add_column "wa_molecules", "updated_at", :datetime
    WaMolecule.reset_column_information
    WaMolecule.find(:all).each do |molecule|
      molecule.created_at = Time.now
      molecule.updated_at = Time.now
      molecule.save
    end
  end

  def self.down
    remove_column "wa_molecules", "created_at"
    remove_column "wa_molecules", "updated_at"
  end

end
