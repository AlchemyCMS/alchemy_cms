class AddMoleculeCreatedAt < ActiveRecord::Migration
  def self.up
    add_column "molecules", "created_at", :datetime
    add_column "molecules", "updated_at", :datetime
    Molecule.reset_column_information
    Molecule.find(:all).each do |molecule|
      molecule.created_at = Time.now
      molecule.updated_at = Time.now
      molecule.save
    end
  end

  def self.down
    remove_column "molecules", "created_at"
    remove_column "molecules", "updated_at"
  end

end
