class RenameModifiedToUpdated < ActiveRecord::Migration
  def self.up
    WaPage.reset_column_information
    rename_column(:wa_pages, :modified_at, :updated_at)
    rename_column(:wa_pages, :modified_by, :updated_by)
  end

  def self.down
    rename_column(:wa_pages, :updated_at, :modified_at)
    rename_column(:wa_pages, :updated_by, :modified_by)
  end
end