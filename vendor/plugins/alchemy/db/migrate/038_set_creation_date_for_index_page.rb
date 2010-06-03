class SetCreationDateForIndexPage < ActiveRecord::Migration
  def self.up
    root = WaPage.root
    root.created_at = Time.now
    root.created_by = 1
    root.updated_at = Time.now
    root.updated_by = 1
    root.save
  end

  def self.down
    root = WaPage.root
    root.created_at = nil
    root.created_by = nil
    root.updated_at = nil
    root.updated_by = nil
    root.save
  end
end