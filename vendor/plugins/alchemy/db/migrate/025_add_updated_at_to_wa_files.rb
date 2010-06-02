class AddUpdatedAtToWaFiles < ActiveRecord::Migration
  def self.up
    add_column(:wa_files, :created_at, :datetime)
  end

  def self.down
    remove_column :wa_files, :created_at
  end
end
