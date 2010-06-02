class RenameModifiedToUpdated < ActiveRecord::Migration
  def self.up
    Page.reset_column_information
    rename_column(:pages, :modified_at, :updated_at)
    rename_column(:pages, :modified_by, :updated_by)
  end

  def self.down
    rename_column(:pages, :updated_at, :modified_at)
    rename_column(:pages, :updated_by, :modified_by)
  end
end