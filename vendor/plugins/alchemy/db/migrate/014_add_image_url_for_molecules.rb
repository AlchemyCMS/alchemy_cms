class AddImageUrlForMolecules < ActiveRecord::Migration
  def self.up
    add_column(:molecules, :image_url, :string)
  end

  def self.down
    remove_column(:molecules, :image_url)
  end
end
