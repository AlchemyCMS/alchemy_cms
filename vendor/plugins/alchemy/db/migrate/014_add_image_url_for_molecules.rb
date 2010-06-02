class AddImageUrlForMolecules < ActiveRecord::Migration
  def self.up
    add_column(:wa_molecules, :image_url, :string)
  end

  def self.down
    remove_column(:wa_molecules, :image_url)
  end
end
